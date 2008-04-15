class WelcomeController < ApplicationController

layout "index"
  

  def index
    unless session[:user].blank? == false
        redirect_to :action => :nologin
    else
      @news = News.find(:all, :limit => 10, :order => "create_at DESC")
    end
        
  end

  def nologin

  end

  def login
    if session[:user].blank? == false
        redirect_to :action => :index
    else
    if request.post?
      begin
        @login = params[:user][:login]
        session[:user] = User.authenticate(@login,params[:user][:password]).id
        session[:persone] = User.authenticate(@login,params[:user][:password])
        @uu=User.find(session[:user])
        session[:firm]= @uu.firm_id
        session[:status]= @uu.status
        if session[:status]==3
          session[:admin]=true
        end
        session[:name] = @login
        flash[:notice] = "Добро пожаловать!"
        redirect_to :controller =>:welcome, :action => :index 
      rescue
        flash[:error] = "Имя пользователя или пароль не подходит!"
      end
    end
    end
  end

  def logout
	session[:user] = nil
	session[:name] = nil
	redirect_to :controller => :welcome, :action => :index
  end



end
