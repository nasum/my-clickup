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
    @client.show
  end

  desc "team", "list all teams"

  def team
    @client.teams
  end
end
