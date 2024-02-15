module UsersController
  module Helpers
    require 'bcrypt'
    include BCrypt

    def user_params
      params.slice(:email, :password, :confirm_password)
    end
  end

  def self.registered(app)
    app.helpers Helpers

    app.post '/signup' do
      content_type :json
      
      Authentication.signup(params, settings)
    end

    app.post '/verify_email/:id' do
      content_type :json
      
      Authentication.verify_email(params)    
    end

    app.post '/login' do
      content_type :json

      Authentication.login(params, settings)
    end

    app.post '/verify_otp/:id' do
      content_type :json

      Authenticator.verify_otp(params)
    end

    app.post '/request_change_2fa_status' do
      content_type :json
      token = request.env['HTTP_AUTHORIZATION']&.split(' ')&.last
      
      Authenticator.request_change_2fa_status(token, settings)
    end

    app.post '/update_2fa_status' do
      content_type :json
      token = request.env['HTTP_AUTHORIZATION']&.split(' ')&.last

      Authenticator.update_2fa_status(token, params)
    end

    app.post '/reset_password' do
      content_type :json
      token = request.env['HTTP_AUTHORIZATION']&.split(' ')&.last

      Authentication.reset_password(token, params)
    end
  end
end
