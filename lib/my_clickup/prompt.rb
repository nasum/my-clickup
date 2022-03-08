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
    @context = MyClickup::Context.new
    @cmd = MyClickup::Cmd.new(client, @context)
  end

  def start
    while buf = Readline.readline("#{@context} $ ", true)
      process(buf)
    end
  end

  def process(buf)
    case buf
    when /^context$/
      @cmd.context
    when /^cd$/
      @cmd.cd
    when /^cd (.*)$/
      @cmd.cd Regexp.last_match 1
    when /^ls$/
      @cmd.ls
    when /^ls (.*)$/
      @cmd.ls Regexp.last_match 1
    when /^exit$/
      @cmd.do_exit
    else
      puts "unknown command: #{buf}"
    end
  end
end
