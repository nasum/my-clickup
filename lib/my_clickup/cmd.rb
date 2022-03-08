# frozen_string_literal: true

require "my_clickup/context"

class MyClickup::Cmd
  def initialize(client, context)
    @client = client
    @context = context
  end

  def context
    puts JSON.pretty_generate @context.to_h
  end

  def cd(dir = nil)
    obj = ls.filter { |item| item[:name] == dir }.first
    @context.change(obj)
  end

  def ls(dir = nil)
    result = case dir || @context.current
             when "root"
               @client.teams
             when "team"
               @client.spaces(@context.team[:id])
             when "space"
               @client.folders(@context.space[:id])
             when "folder"
               @client.lists(@context.folder[:id])
             when "list"
               @client.tasks(@context.list[:id])
             else
               @client.teams
             end

    puts JSON.pretty_generate result
    result
  end

  def do_exit
    puts "bye"
    exit
  end
end
