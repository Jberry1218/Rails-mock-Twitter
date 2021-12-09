require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup 
    @user = User.new(name: "Example User", email: "user@example.com",
      password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "  "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "  "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.com A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "database should lowercase emails before saving" do
    mixed_case_email = "USER@ExAMPLE.coM"
    @user.email = mixed_case_email
    @user.save
    assert_equal @user.reload.email, mixed_case_email.downcase
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = "         "
    assert_not @user.valid?
  end

  test "password should not be too short" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with a nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed when user destroyed" do
    @user.save
    @user.microposts.create(content: "Lorem Ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    john = users(:john_doe)
    archer = users(:archer)
    assert_not john.following?(archer)
    john.follow(archer)
    assert john.following?(archer)
    assert archer.follower?(john)
    john.unfollow(archer)
    assert_not john.following?(archer)
  end

  test "feed should have the right posts" do 
    john_doe = users(:john_doe)
    archer = users(:archer)
    malory = users(:malory)
    # Posts from self
    john_doe.microposts.each do |post_self|
      assert john_doe.feed.include?(post_self)
    end
    # Posts from followed user
    malory.microposts.each do |post_followed|
      assert john_doe.feed.include?(post_followed)
    end
    # Posts from not followed user
    archer.microposts.each do |post_not_followed|
      assert_not john_doe.feed.include?(post_not_followed)
    end
  end
end