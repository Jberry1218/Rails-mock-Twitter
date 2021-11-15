require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:john_doe)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    user = {
      email: "",
      password: ""
    }
    post login_path, params: { session: user }
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid email but invalid password" do
    get login_path
    assert_template 'sessions/new'
    user = {
      email: @user.email,
      password: ""
    }
    post login_path, params: { session: user }
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information then logout" do 
    get login_path
    assert_template 'sessions/new'
    user = {
      email: @user.email,
      password: "password"
    }
    post login_path, params: { session: user }
    assert is_logged_in?
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
