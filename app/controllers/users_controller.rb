class UsersController < ApplicationController
 layout "index"
 #before_filter :check_authentication

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
  if session[:status]==2 || session[:status]==3 || session[:status]==4
        @users = User.find(:all)
  elsif session[:status]==5
        @users = User.find(:all, :conditions => ["firm_id=?", session[:firm]])
  else
        @users=nil
  end
  end
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if(@user.parent_id.nil?)
      @user.parent_id= 0
    end
    if session[:status]==5
      @user.firm_id=session[:firm]
    end
    @user.create_at = Time.now
    if @user.save
      flash[:notice] = 'Пользователь создан.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end



  def register
    redirect_to :action => :new
  end


end
