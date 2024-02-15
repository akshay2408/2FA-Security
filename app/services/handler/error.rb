require 'yaml'

module Handler
  module Error
    @error_messages = YAML.load_file('config/messages.yml')

    def self.error_message(key)
      @error_messages['errors'][key]
    end
  end
end
