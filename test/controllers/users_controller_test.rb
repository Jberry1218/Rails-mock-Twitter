require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:john_doe)
    @other_user = users(:rand)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "edit path should redirect to login when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "update attempts should redirect to login when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email

                                            }
                                    }
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "edit path should redirect when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_path
  end

  test "update attempts should redirect when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email

                                            }
                                    }
    assert flash.empty?
    assert_redirected_to root_path
  end

  test "index path should redirect when not logged in" do
    get(users_path)
    assert_redirected_to(login_path)
  end

  test "should not allow admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: { admin: true }}
    @other_user.reload
    assert_not @other_user.admin?
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@other_user)
    end
    assert_redirected_to(login_path)
  end

  test "should redirect destroy when not admin user" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to(root_path)
  end
end
