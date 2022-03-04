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

  def get_teams
    connection.get("team").body
  end
end
