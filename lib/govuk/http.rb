require "yaml"
require "json"
require "net/http"

module HTTP
  def self.get_yaml(url)
    YAML.load(get(url))
  end

  def self.get_json(url)
    JSON.parse(get(url))
  end

  def self.get(url)
    Net::HTTP.get(URI(url))
  end
end
