# frozen_string_literal: true

require_relative "my_clickup/version"
require_relative "my_clickup/client"
require_relative "my_clickup/cli"
require_relative "my_clickup/prompt"

# my_clickup.rb
module MyClickup
  class Error < StandardError; end
  MyClickup::Cli.start(ARGV)
end
