require 'json'
require 'jwt'

module Authentication
  extend self

  def login(params, settings)
    user = User.find(email: params[:email])

    if user && BCrypt::Password.new(user.password_digest) == params[:password]
      
      if user.two_factor_auth
        Mail.send_otp_verification(user, settings)
        return success_response('login_2fa_require')
      end
      success_response('login_success', user)
    else
      error_response('invalid_credentials')
    end
  end

  def signup(params, settings)
    return error_response('already_registered') if User.find(email: params[:email])

    user = User.new(params)

    if passwords_match?(params[:password], params[:confirm_password])
      salt = User.generate_salt
      user.salt = salt
      user.password_digest = password_digest(params[:password], salt)

      if user.save
        Mail.send_activation_email(user, settings)
        success_response('activation_sent')
      else
        error_message(user.errors.full_messages.join(', '))
      end
    else
      error_response('password_not_macth')
    end
  end  

  def verify_email(params)
    user = User.find(uuid: params[:id])
  
    if user
      if user.email_verified
        message = 'email_already_verified'
      else
        user.update(email_verified: true)
        message = 'email_verified'
      end
      success_response(message)
    else
      error_response('invalid_link')
    end
  end

  def reset_password(token, params)
    user = current_user(token)
    current_password = params[:current_password]
    new_password = params[:new_password]
    confirm_password = params[:confirm_password]
  
    return error_response('invalid_password') unless user || valid_current_password?(user, current_password)
    return error_response('new_password_not_match') unless passwords_match?(new_password, confirm_password)
  
    update_user_password(user, new_password)
    success_response('password_reset')
  end
  
  private

  def valid_current_password?(user, current_password)
    BCrypt::Password.new(user.password_digest) == current_password
  end
  
  def passwords_match?(password, confirm_password)
    password == confirm_password
  end

  def update_user_password(user, new_password)
    salt = User.generate_salt
    user.update(password_digest: password_digest(new_password, salt), salt: salt)
  end

  def current_user(token)
    decoded_token = JWT.decode(token, jwt_secret_key, true, algorithm: 'HS256')
    User.find(id: decoded_token.first['user_id'])    
  end

  def jwt_token(user_id)
    JWT.encode({ user_id: user_id }, jwt_secret_key, 'HS256')
  end

  def jwt_secret_key
    ENV.fetch('JWT_SECRET_KEY')
  end

  def password_digest(password, salt)
    BCrypt::Engine.hash_secret(password, salt)
  end

  def success_response(key, user = nil)
    response = { message: Handler::Success.success_message(key) }
    response[:token] = jwt_token(user.id) if user
    response.to_json
  end
  
  def error_response(key)
    { message: Handler::Error.error_message(key) }.to_json
  end

  def error_message(message)
    { status: 'error', message: message }.to_json
  end
end
