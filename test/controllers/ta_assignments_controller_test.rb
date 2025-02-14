require "test_helper"

class TaAssignmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get ta_assignments_new_url
    assert_response :success
  end

  test "should get create" do
    get ta_assignments_create_url
    assert_response :success
  end
end
