# frozen_string_literal: true

# config.rb
class MyClickup::Config
  attr_reader :api_token, :config_dir, :config_file

  def initialize
    @api_token = ENV["MY_CLICKUP_API_TOKEN"]
    @config_dir = File.expand_path("~/.my_clickup")
    @config_file = File.join(@config_dir, "config.yml")
  end
end
