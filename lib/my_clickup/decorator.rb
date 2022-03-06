# frozen_string_literal: true

# decoder.rb
module MyClickup::Decorator
  def decorate_user(user)
    {
      id: user["id"],
      username: user["username"],
      email: user["email"],
      color: user["color"],
      profilePicture: user["profilePicture"]
    }
  end

  def decorate_team(team)
    {
      id: team["id"],
      name: team["name"],
      color: team["color"],
      avatar: team["avatar"]
    }
  end

  def decorate_space(space)
    {
      id: space["id"],
      name: space["name"],
      statuses: space["statuses"]
    }
  end
end
