require 'test_helper'

class TwitterBotsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get twitter_bots_index_url
    assert_response :success
  end

end
