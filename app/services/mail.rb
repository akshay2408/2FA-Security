require 'bcrypt'
require 'securerandom'

module Mail
  extend self

  def generate_otp
    SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')
  end

  def send_email(user, subject, body, settings)
    mail_data = Mail.new do
      from    ENV['SMTP_EMAIL']
      to      user.email
      subject subject
      body    body
    end
  
    if settings.production?
      mail_data.delivery_method :smtp, settings.smtp_options
    else
      mail_data.delivery_method LetterOpener::DeliveryMethod, location: File.expand_path('tmp/letter_opener', __dir__)
    end
  
    mail_data.deliver!
  end

  def send_activation_email(user, settings)
    confirmation_link = "#{Base.base_url}/verify_email/#{user.uuid}"
    body = "#{mail_message('active')}\n#{confirmation_link}"
    send_email(user, mail_message('email_varification'), body, settings)
  end

  def send_otp_verification(user, settings)
    otp = generate_otp
    user.update(otp: otp)
    confirmation_link = "#{Base.base_url}/verify_otp/#{user.uuid}"
    body = "#{mail_message('here_otp')}#{otp} \n #{confirmation_link}"
    send_email(user, mail_message('otp_varification'), body, settings)
  end

  def otp_verification_2fa(user, settings)
    otp = generate_otp
    user.update(otp: otp)
    body = "#{mail_message('here_otp_2fa')}#{otp}"
    send_email(user, mail_message('otp_varification'), body, settings)
  end

  def reset_password_email(user, settings)
    reset_link = "#{Base.base_url}/reset_password/#{user.reset_token}"
    body = "#{mail_message('reset_password')}\n#{reset_link}"
    send_email(user, mail_message('reset_password'), body, settings)
  end

  def send_password_reset_email(user)
    reset_token = User.generate_reset_token
    user.update(reset_token: reset_token)
    reset_password_email(user)
  end

  private

  def mail_message(key)
    Handler::Mail.mail_message(key)
  end
end
