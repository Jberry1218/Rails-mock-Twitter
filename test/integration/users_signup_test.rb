require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    user = {
      name: " ",
      email: "user@invlaid",
      password: "foo",
      password_confirmation: "bar"
    }
    assert_no_difference 'User.count' do
      post users_path, params: { user: user }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup" do
    get signup_path
    user = {
      name: "John Doe",
      email: "user@example.com",
      password: "example_password",
      password_confirmation: "example_password"
    }
    assert_difference 'User.count', 1 do
      post users_path, params: { user: user }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
end
