module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  #返回当前登录的用户
  def current_user
    if(user_id = session[:user_id])
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: cookies.signed[:user_id])
      @current_user = user if (user && user.authenticated?(:remember,cookies[:user_remember_token]))
      log_in user
    end
  end

  #每一次调用logged_in?方法，都会查看当前session中是否登录
  def logged_in?
    !current_user.nil?
  end

  #在持久会话(cookies)中保存用户信息
  def remember(user)
     #生成新的remember_token,同时将remember_token的值加密存放在user对象的remember_digest字段中，存入数据库
     user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:user_remember_token] = user.remember_token
  end

  #在持久会话(cookies)中删除用户信息
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:user_remember_token)
  end

  def currect_user?(user)
    user == current_user
  end

  #存储后面需要跳转的地址
  def store_location
    session[:forwording_url] = request.original_url if request.get?
  end

  # 重定向到存储的地址或者默认地址
  def redirect_back_or(default)
    redirect_to( session[:forwording_url] || default)
    session.delete(:forwording_url)
  end

end
