require 'yaml'

module Handler
  module Success
    @success_messages = YAML.load_file('config/messages.yml')

    def self.success_message(key)
      @success_messages['success'][key]
    end
  end
end
