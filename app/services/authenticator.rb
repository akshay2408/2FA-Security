require 'json'
require 'jwt'

module Authenticator
  extend self

  def verify_otp(params)
    user = User.find(uuid: params[:id])

    if user && user.otp == params[:otp]
      user.update(otp: nil)
      success_response('verify_otp_success', user)
    else
      error_response('invalid_otp')
    end
  end

  def request_change_2fa_status(token, settings)
    user = current_user(token)

    if user
      Mail.otp_verification_2fa(user, settings)
      success_response('request_change_2fa_success', user)
    else
      error_response('user_not_found')
    end
  end

  def update_2fa_status(token, params)
    user = current_user(token)

    if user && user.otp == params[:otp]
      user.update(two_factor_auth: params[:enable_2fa], otp: nil)
      success_response('updated_2fa', user)
    else
      error_response('invalid_otp')
    end
  end
  
  private

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

  def success_response(key, user)
    { message: Handler::Success.success_message(key), token: jwt_token(user.id) }.to_json
  end
  
  def error_response(key)
    { message: Handler::Error.error_message(key) }.to_json
  end
end
