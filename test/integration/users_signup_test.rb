require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

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

  test "valid signup information with account_activation" do
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
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    # Try to log in before activation
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("Invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    # Valid token and email
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert is_logged_in?
    assert user.reload.activated?
    follow_redirect!
    assert_template "users/show"
  end
end
