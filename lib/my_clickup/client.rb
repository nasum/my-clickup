# frozen_string_literal: true

require "fileutils"
require "faraday"
require "my_clickup/config"

# clickup client
class MyClickup::Client
  BASE_URL = "https://api.clickup.com/api/v2/"

  def initialize(options = {})
    @config = MyClickup::Config.new
    @api_token = options[:api_token] || @config.api_token
  end

  def connection
    Faraday.new do |builder|
      builder.url_prefix = BASE_URL
      builder.request :json
      builder.request :authorization, "", @api_token
      builder.response :json, content_type: "application/json"
      builder.adapter :net_http
    end
  end

  def init
    FileUtils.mkdir_p(@config.config_dir) unless File.exist?(@config.config_dir)
    FileUtils.touch(@config.config_file) unless File.exist?(@config.config_file)
  end

  def me
    connection.get("user").body
  end

  def teams
    connection.get("team").body["teams"].map do |team|
      {
        id: team["id"],
        name: team["name"],
        color: team["color"],
        avatar: team["avatar"]
      }
    end
  end

  def spaces(team_id, archived: false)
    spaces = connection.get("team/#{team_id}/space", { archived: archived }).body["spaces"]
    spaces.map do |space|
      {
        id: space["id"],
        name: space["name"],
        statuses: space["statuses"]
      }
    end
  end

  def my_tasks
    connection.get("task").body
  end
end
