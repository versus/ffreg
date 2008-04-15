# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#require_dependency 'user'
#require_dependency 'role'
#require_dependency 'static_permission'

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_GrandTotal_session_id'
  #session[:user] = nil
  #session[:user][:name] = 'Anonymous'

 @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
        

  def check_authentication
    if session[:user].blank?
 #     session[:intended_controller] = controller_name
 #     session[:intended_action] = action_name
      
      redirect_to :controller => 'welcome', :action => 'login'
    end
  end
end
