# frozen_string_literal: true

require "faraday"

# clickup client
class MyClickup::Client
  BASE_URL = "https://api.clickup.com/api/v2/"

  def initialize(options = {})
    @api_token = options[:api_token] || ENV["MY_CLICKUP_API_TOKEN"]
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