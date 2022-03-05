# frozen_string_literal: true

require "thor"

# cli
class MyClickup::Cli < Thor
  desc "team", "list all teams"

  def team
    puts MyClickup::Client.new.teams
  end
end
