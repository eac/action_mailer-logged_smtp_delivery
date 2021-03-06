require 'action_mailer'
require 'active_support/core_ext/class/attribute'
require 'net/smtp'

#TODO: Add mail file logger

# A few features:
# Hides BCC recipients
# Detailed log stream with message id token
# Logs an identification header to quickly locate logs for a specific email
# Can optionally log the raw email
# TLS support
module ActionMailer::LoggedSMTPDelivery

  def self.included(base)
    base.class_attribute :mail_file_logger
  end

  def perform_delivery_logged_smtp(mail)
    delivery        = SMTPDelivery.new(mail, smtp_settings)
    delivery.logger = logger

    if mail_file_logger
      path = mail_file_logger.log(mail.encoded)
      delivery.log "stored at #{path}"
    end

    delivery.perform
  end

  class SMTPDelivery

    attr_reader   :mail, :settings
    attr_accessor :logger

    def initialize(mail, settings)
      @mail         = mail
      @settings     = settings
    end

    def perform
      log_headers
      log "sender: #{sender}"
      log "destinations: #{destinations.inspect}"

      smtp.start(*settings.values_at(:domain, :user_name, :password, :authentication)) do |session|
        response = session.send_message(message, sender, destinations)
        log "done #{response.inspect}"
      end
    end

    def destinations
      mail.destinations
    end

    def message
      original_bcc = mail.bcc
      mail.bcc     = nil
      mail.encoded
    ensure
      mail.bcc = original_bcc
    end

    def sender
      mail.from.first
    end

    def log_header
      settings[:log_header]
    end

    def smtp
      smtp_adaptor.new(settings[:address], settings[:port]).tap do |smtp|
        smtp.enable_starttls_auto if enable_tls?
      end
    end

    def log_headers
      log "#{log_header}: [#{mail[log_header]}]" unless log_header.nil?
    end

    def log(message)
      logger.info("#{mail.message_id} #{message}")
    end

    def enable_tls?
      settings[:tls] != false
    end

    def smtp_adaptor
      settings[:adaptor] || Net::SMTP
    end

  end

end
