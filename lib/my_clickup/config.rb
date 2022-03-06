# frozen_string_literal: true

# config.rb
class MyClickup::Config
  attr_reader :api_token, :config_dir, :config_file, :clickup_info

  def initialize
    @api_token = ENV["MY_CLICKUP_API_TOKEN"]
    @config_dir = File.expand_path("~/.my_clickup")
    @config_file = File.join(@config_dir, "config.json")
    @clickup_info = File.join(@config_dir, "clickup_info.json")
  end

  def default
    {
      team: "",
      space: ""
    }
  end
end
