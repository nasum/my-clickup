# frozen_string_literal: true

require "thor"

# cli
class MyClickup::Cli < Thor
  def initialize(*options)
    super
    @client = MyClickup::Client.new
  end

  desc "init", "Initialize the configuration"
  def init
    @client.init
  end

  desc "show", "show my clickup information"
  def show
    puts JSON.pretty_generate @client.show
  end

  desc "me", "get my info"
  def me
    puts JSON.pretty_generate @client.me
  end

  desc "teams", "list all teams"
  def teams
    puts JSON.pretty_generate @client.teams
  end

  desc "all_spaces", "list all spaces"
  def all_spaces
    puts JSON.pretty_generate @client.all_spaces
  end
end
