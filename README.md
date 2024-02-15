# Authentify

This application is using:
* Sinatra framework
* Postgresql
* Sequel as ORM


## Database

### Create database
Before running the migrations we need to create a database.

Connecto to Postgresql and run the following command.
```
CREATE DATABASE [database_name];
CREATE DATABASE user_auth;
CREATE DATABASE user_auth_test;
```

### Configure database
There is an example DB configuration file `database.yml.example` placed in `config` folder.

* Create real configuration file from the example
  * `cp database.yml.example database.yml`
* Change the values in the configuration file

### Run migrations
```
sequel config/database.yml -e [env] -E -t -m db/migrations
sequel config/database.yml -e development -E -t -m db/migrations
```

### How to create a migration file
In order to change the database schema, create a file in `db/migrations` folder with name like `[timestamp]_[action].rb`. E.g. `001_create_users.rb`.

## Run the application
```
bundle exec rackup
```

## API Endpoints

### 1. Sign Up
- **Method:** `POST`
- **Endpoint:** `/signup`
- **Request Body:**
  ```json
  {
    "email": "",
    "password": "",
    "confirm_password": ""
  }

After signing up, the user will receive a confirmation email. Copy the link from the email and paste it in Step 2.

### 2. Verify Email
- **Method:** `POST`
- **Endpoint:** `/verify_email/[uuid]`

### 2. Login
- **Method:** `POST`
- **Endpoint:** `/login`
- **Request Body:**
  ```json
  {
    "email": "",
    "password": "",
  }

After logging in, the user will receive a 2FA (Two-Factor Authentication) OTP for verification. Copy the OTP from the email and hit the Verify OTP API.

### 3. Verify OTP
- **Method:** `POST`
- **Endpoint:** `/verify_otp/[uuid]`
- **Request Body:**
  ```json
  {
    "otp": ""
  }

### 4. Request for change 2FA status
- **Method:** `POST`
- **Endpoint:** `/request_change_2fa_status`
- **Bearer Token:** Required

### 5. Update 2FA status
- **Method:** `POST`
- **Endpoint:** `/update_2fa_status`
- **Bearer Token:** Required
- **Request Body:**
  ```json
  {
    "otp": "",
    "enable_2fa": false
  }

### 6. Reset Password
- **Method:** `POST`
- **Endpoint:** `/reset_password`
- **Bearer Token:** Required
- **Request Body:**
  ```json
  {
    "current_password": "",
    "new_password": "",
    "confirm_password": ""
  }
