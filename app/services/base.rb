module Base
  extend self
  def self.base_url
    @base_url ||= ENV.fetch('BASE_URL', 'http://localhost:9292')
  end
end
