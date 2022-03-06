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
    me_val = me force_update: true

    puts "get team info"
    teams_val = teams force_update: true

    puts "get spaces info"
    spaces_val = all_spaces force_update: true

    clickup_info = File.open(@config.clickup_info, "w")
    clickup_info.write(JSON.pretty_generate({
                                              me: me_val,
                                              teams: teams_val,
                                              spaces: spaces_val
                                            }))
  end

  def show
    clickup_info = File.open(@config.clickup_info, "r")
    JSON.parse(clickup_info.read)
  end

  def me(force_update: false)
    if !force_update && File.exist?(@config.clickup_info)
      show["me"]
    else
      user = connection.get("user").body["user"]
      decorate_user(user)
    end
  end

  def teams(force_update: false)
    if !force_update && File.exist?(@config.clickup_info)
      show["teams"].map do |team|
        decorate_team team
      end
    else
      connection.get("team").body["teams"].map do |team|
        decorate_team team
      end
    end
  end

  def spaces(team_id, force_update: false, archived: false)
    if !force_update && File.exist?(@config.clickup_info)
      show["spaces"]
    else
      spaces = connection.get("team/#{team_id}/space", { archived: }).body["spaces"]
      spaces.map do |space|
        decorate_space space
      end
    end
  end

  def all_spaces(force_update: false)
    if !force_update && File.exist?(@config.clickup_info)
      show["spaces"]
    else
      all_space_obj = {}
      teams(force_update:).map do |team|
        all_space_obj[team[:id]] = spaces(team[:id], force_update:)
      end
      all_space_obj
    end
  end

  def my_tasks
    connection.get("task").body
  end

  private

  def decorate_user(user)
    {
      id: user["id"],
      username: user["username"],
      email: user["email"],
      color: user["color"],
      profilePicture: user["profilePicture"]
    }
  end

  def decorate_team(team)
    {
      id: team["id"],
      name: team["name"],
      color: team["color"],
      avatar: team["avatar"]
    }
  end

  def decorate_space(space)
    {
      id: space["id"],
      name: space["name"],
      statuses: space["statuses"]
    }
  end
end
