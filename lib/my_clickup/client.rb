# frozen_string_literal: true

require "readline"
require "fileutils"
require "faraday"
require "my_clickup/config"
require "my_clickup/decorator"

# clickup client
class MyClickup::Client
  include MyClickup::Decorator

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

    craete_config_prompt(teams_val)

    puts "Done"
  end

  def craete_config_prompt(teams_val)
    puts "Create Config file"

    FileUtils.touch(@config.config_file) unless File.exist?(@config.config_file)
    default_config = @config.default

    team_map = {}
    teams_val.each do |team|
      team_map[team[:name]] = team[:id]
    end

    puts "set default team"
    puts "select: #{teams_val.map { |team| (team[:name]).to_s }.join(", ")}"
    print "default team: "
    input = Readline.readline
    default_config[:team] = team_map[input]

    config = File.open(@config.config_file, "w")
    config.write(JSON.pretty_generate(default_config))
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
      show["teams"]
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

  def folders(space_id:)
    connection.get("space/#{space_id}/folder").body
  end

  def lists(space_id:)
    connection.get("space/#{space_id}/list").body
  end

  def tasks(list_id:)
    connection.get("list/#{list_id}/task", { assignees: [me["id"].to_i] }).body
  end
end
