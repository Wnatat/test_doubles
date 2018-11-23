class SystemUnderTest
  def initialize(auth)
    @authenticator = auth
    @active_users = 0
  end

  attr_reader :active_users

  def login(username, password)
    @authenticator.attempt(username, password)
  end

  def logout
    @authenticator.logout
  end
end