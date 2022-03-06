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

  desc "folders", "list all folders"
  option :space_id
  def folders
    puts JSON.pretty_generate @client.folders(space_id: options[:space_id])
  end

  desc "lists", "list all lists"
  option :space_id
  def lists
    puts JSON.pretty_generate @client.lists(space_id: options[:space_id])
  end

  desc "tasks", "list all tasks"
  option :list_id
  def tasks
    puts JSON.pretty_generate @client.tasks(list_id: options[:list_id])
  end
end
