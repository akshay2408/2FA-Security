require 'securerandom'

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :uuid, default: SecureRandom.uuid, null: false, unique: true
      String :email, null: false, unique: true
      Boolean :email_verified, default: false
      String :password_digest, null: false
      String :salt, default: SecureRandom.hex(16), null: false
      String :reset_token, default: false, null: true
      String :otp
      Boolean :two_factor_auth, default: true
      
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
