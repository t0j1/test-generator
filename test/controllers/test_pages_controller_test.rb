require "test_helper"

class TestPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get test_pages_index_url
    assert_response :success
  end
end
