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

  def me
    user = connection.get("user").body["user"]
    decorate_user(user)
  end

  def teams
    connection.get("team").body["teams"].map do |team|
      decorate_team team
    end
  end

  def spaces(team_id, archived: false)
    spaces = connection.get("team/#{team_id}/space", { archived: }).body["spaces"]
    spaces.map do |space|
      decorate_space space
    end
  end

  def all_spaces
    all_space_obj = {}
    teams(force_update:).map do |team|
      all_space_obj[team[:id]] = spaces(team[:id], force_update:)
    end
    all_space_obj
  end

  def folders(space_id)
    connection.get("space/#{space_id}/folder").body
  end

  def lists(space_id)
    connection.get("space/#{space_id}/list").body
  end

  def tasks(list_id)
    connection.get("list/#{list_id}/task", { assignees: [me["id"].to_i] }).body
  end
end
