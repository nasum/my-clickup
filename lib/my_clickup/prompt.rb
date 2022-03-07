# frozen_string_literal: true

require "readline"
require "my_clickup/context"

# prompt.rb
class MyClickup::Prompt
  WORDS = %w[cd ls exit]

  Readline.completion_proc = proc do |word|
    WORDS.grep(/\A#{Regexp.quote word}/)
  end

  def initialize(client)
    @client = client
    @context = MyClickup::Context.new
  end

  def start
    while buf = Readline.readline("#{@context} $ ", true)
      process(buf)
    end
  end

  def process(buf)
    case buf
    when /^context$/
      puts JSON.pretty_generate @context.to_h
    when /^cd$/
      cd
    when /^cd (.*)$/
      cd(Regexp.last_match(1))
    when /^ls$/
      puts JSON.pretty_generate ls
    when /^ls (.*)$/
      puts JSON.pretty_generate ls(Regexp.last_match(1))
    when /^exit$/
      puts "bye"
      exit
    else
      puts "unknown command: #{buf}"
    end
  end

  def cd(dir = nil)
    obj = ls.filter { |item| item[:name] == dir }.first
    @context.change(obj)
  end

  def ls(dir = nil)
    case dir || @context.current
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
  end
end
