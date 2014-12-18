require 'mandrill'
require 'yaml'

# Uses the Mandrill Rest Api so I do not have to mess with SMTP.
module Mailer
  extend self

  # Sends email to mandrill and then exits
  def send_message(message)
    mandrill = Mandrill::API.new(get_api_key)

    email = {
      subject: 'Exception generated during theme creation',
      from_name: 'WP-Braces Admin',
      text: html_template(message),
      to: [
          {
          email: 'neb636@gmail.com',
          name: 'Nick'
        }
      ],
      html: html_template(message),
      from_email: "Admin@wp-braces.com"
    }

    mandrill.messages.send(email)
  end

  private

  def html_template(message)
    <<-EOT
      <h2>There was a exception during theme creation</h2>
      <p style="font-size: 14px;">The exception message is <em>#{message[:error]}.</em>
    EOT
  end

  def get_api_key
    client_secrets = YAML.load_file('client_secrets.yml')
    client_secrets['mandrill_api_key']
  end
end