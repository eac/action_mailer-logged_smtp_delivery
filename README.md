### Logged SMTP Delivery

A few features:
  1. Detailed log stream with message id prefix. Example:
   ```
   <4e2b38d772949_b81ac212@localhost> stored at example/log/mails/outbound/2011-07-23/7_13462_2.eml
   <4e2b38d772949_b81ac212@localhost> X-Delivery-Context: [users/1/welcome]
   <4e2b38d772949_b81ac212@localhost> sender: support@support.localhost
   <4e2b38d772949_b81ac212@localhost> destinations: support@system.example.com
   <4e2b38d772949_b81ac212@localhost> done #<Net::SMTP::Response:0x10bbee680 @string="250 2.0.0 Ok: queued as 87BF716D7901\n", @status="250">
   ```

  2. Logs an identification header to quickly locate logs for a specific email/entity
    ```ruby
    config.action_mailer.smtp_settings[:log_header] = 'X-Delivery-Context'

    class UsersMailer < ActionMailer::Base
      
      def welcome(user)
        headers['X-Delivery-Context'] = "users/#{user.id}/welcome"
        
        # ...
      end
    end
    

    UsersMailer.deliver_welcome(user)
    # ActionMailer::Base.logger -> 
    # <4e2b38d772949_b81ac212@localhost> X-Delivery-Context: [users/1/welcome]
    ```
  
  3. Doesn't render BCC recipients

