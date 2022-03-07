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
    while buf = Readline.readline("> ", true)
      process(buf)
    end
  end

  def process(buf)
    case buf
    when /^cd$/
      cd
    when /^cd (.*)$/
      cd(Regexp.last_match(1))
    when /^ls$/
      ls
    when /^ls (.*)$/
      ls(Regexp.last_match(1))
    when /^exit$/
      puts "bye"
      exit
    else
      puts "unknown command: #{buf}"
    end
  end

  def cd(dir = "")
    puts dir
  end

  def ls(dir = "")
    puts dir
  end
end
