require 'test_helper'

class TranslationsControllerTest < ActionController::TestCase
  setup do
    @translation = translations(:one)
    @post = @translation.post
  end

  context "logged in user" do
    should "get new" do
      login_as users(:one)
      get :new, :post_id => @post.number.to_s
      assert_response :success
    end

    should "create translation" do
      login_as users(:one)
      assert_difference('Translation.count') do
        post :create, :post_id => @post.number.to_s,
                      :translation => @translation.attributes
      end

      assert_redirected_to post_path(assigns(:translation).post)
    end
  end

  context "guest user" do
    should "not get new" do
      logout
      get :new, :post_id => @post.number.to_s
      assert_not_nil flash[:error]
    end

    should "not create translation" do
      logout
      assert_no_difference('Translation.count') do
        post :create, :post_id => @post.number.to_s,
                      :translation => @translation.attributes
      end
      assert_not_nil flash[:error]
    end
  end

end
