require 'test_helper'

class CoursesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get search" do
    get :search
    assert_response :success
  end

  test "should get add" do
    get :add
    assert_response :success
  end

end
