class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :signed_in?

  private

  def login_as(user)
    reset_session
    session[:user_id] = user.id  
  end

  def require_login
    if not signed_in?
      redirect_to login_required_path(path: request.fullpath),
        flash: {error: "Login required!"}
    end
  end

  def current_user  
    (@current_user ||= User.find(session[:user_id])) if session[:user_id]  
  end  
  
  def signed_in?
    current_user
  end

  def not_found
    render text: "NOT FOUND", status: 404
  end

  def find_post
    @post = Post.find(params[:post_id] || params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

end
