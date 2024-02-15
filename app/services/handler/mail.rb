require 'yaml'

module Handler
  module Mail
    @mail_messages = YAML.load_file('config/messages.yml')

    def self.mail_message(key)
      @mail_messages['mail'][key]
    end
  end
end
