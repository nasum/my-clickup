# frozen_string_literal: true

class MyClickup::Context
  attr_accessor :team, :space, :folder, :list

  def initialize
    @team = nil
    @space = nil
    @folder = nil
    @list = nil
  end

  def current
    if @list
      "list"
    elsif @folder
      "folder"
    elsif @space
      "space"
    elsif @team
      "team"
    else
      "root"
    end
  end

  def change(dir)
    if !team
      @team = dir
    elsif !space
      @space = dir
    elsif !folder
      @folder = dir
    elsif !list
      @list = dir
    end
  end

  def to_h
    {
      team: @team,
      space: @space,
      folder: @folder,
      list: @list
    }
  end

  def to_s
    (@team ? "/#{@team[:name]}" : "/") +
      (@space ? "/#{@space[:name]}" : "") +
      (@folder ? "/#{@folder[:name]}" : "") +
      (@list ? "/#{@list[:name]}" : "")
  end
end
