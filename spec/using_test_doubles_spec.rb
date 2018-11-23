require 'system_under_test'

class Dummy
  def attempt(username, password)
    raise RuntimeError
  end
end

class Stub
  def attempt(username, password)
    true
  end
end

class Spy
  def initialize
    @attemptWasCalled = false
  end

  attr_reader :attemptWasCalled

  def attempt(username, password)
    @attemptWasCalled = true
    true
  end
end

class Mock
  def initialize
    @logoutWasCalled = false
    @redirectWasCalled = false
  end

  def verify
    @logoutWasCalled && @redirectWasCalled
  end

  def logout
    @logoutWasCalled = true
    redirect
  end

  def redirect
    @redirectWasCalled = true
  end
end

class Fake
  def initialize
    @users = {
      foo: 'bar',
      baz: 'qux'
    }
  end

  def attempt(username, password)
    @users.key?(username.to_sym) && @users[username.to_sym] == password
  end
end

describe SystemUnderTest do
  subject { described_class.new(double) }

  context "when we need to ensure a collaborator is never exercised" do
    let(:double) { Dummy.new }

    it "doesn't use authenticator to get current active users" do
      expect(subject.active_users).to eq 0
    end

    it "doesn't allow to use authenticator" do
      expect {subject.login('foo', 'bar') }.to raise_error RuntimeError
    end
  end

  context "when SUT needs an indirect input" do
    let(:double) { Stub.new }

    it "uses a stub to read result from successful authenticator" do
      expect(subject.login('foo', 'bar')).to eq true
    end
  end

  context "when SUT needs an indirect output" do
    let(:double) { Spy.new }

    it "uses a spy to verify a collaborator received an interaction" do
      expect(subject.login('foo', 'bar')).to eq true
      expect(double.attemptWasCalled).to eq true
    end
  end

  context "when we need to refactor duplicate spy verifications" do
    let(:double) { Mock.new }

    it "uses a mock to verify a certain behavior happened during interaction" do
      subject.logout
      expect(double.verify).to eq true
    end
  end

  context "when we want to replace the functionalities of a collaborator without verifications or nonexistant" do
    let(:double) { Fake.new }

    it "implements a collaborator interface in a simpler way" do
      expect(subject.login('foo', 'bar')).to eq true
    end
  end
end
