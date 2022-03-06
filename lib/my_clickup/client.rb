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
    FileUtils.touch(@config.clickup_info) unless File.exist?(@config.clickup_info)

    puts "Store your Clickup information"

    puts "get my info"
    me_val = me

    puts "get team info"
    teams_val = teams

    puts "get spaces info"
    spaces_val = teams_val.map do |team|
      team_id = team[:id]
      space_val = spaces(team_id)

      {
        team_id: team_id,
        space: space_val
      }
    end

    clickup_info = File.open(@config.clickup_info, "w")
    clickup_info.write(JSON.pretty_generate({
                                              me: me_val,
                                              teams: teams_val,
                                              spaces: spaces_val
                                            }))
  end

  def show
    clickup_info = File.open(@config.clickup_info, "r")
    puts clickup_info.read
  end

  def me
    user = connection.get("user").body["user"]
    {
      id: user["id"],
      username: user["username"],
      email: user["email"],
      color: user["color"],
      profilePicture: user["profilePicture"]
    }
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
