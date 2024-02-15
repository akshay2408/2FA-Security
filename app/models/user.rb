# frozen_string_literal: true

class User < Sequel::Model
  plugin :validation_helpers

  def before_create
    self.uuid = SecureRandom.uuid
    validate_email
  end

  def self.generate_salt
    BCrypt::Engine.generate_salt
  end

  def self.generate_reset_token
    SecureRandom.hex(20)
  end

  def validate
    super
    validates_presence :email
    validates_unique :email
    validates_format URI::MailTo::EMAIL_REGEXP, :email unless email.to_s.empty?
  end

  private

  def validate_email
    regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    regex.match?(email)
  end
end
