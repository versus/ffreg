class AccountsController < ApplicationController

  layout "index"
  before_filter :check_authentication

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if session[:status]==2 || session[:status]==3 || session[:status]==4 || session[:status] ==111
    @firms = Firm.find(:all)
    elsif session[:status]==5
      begin
      @firm = Firm.find_by_id(session[:firm])
      rescue ActiveRecord::RecordNotFound
        flash[:error] ="Ошибка доступа"
      end
    else

      redirect_to :action => "index", :controller => :welcome
    end
  end

  def show
    if session[:status]==5 || session[:status]==6
    @account = Account.find(params[:id], :conditions =>["firm_id=?", session[:firm]])
    elsif session[:status]==2 || session[:status]==3 || session[:status]==4 || session[:status] ==111
    @account = Account.find(params[:id]) 
    end
  end

  def new
    if session[:status]==2 || session[:status]==3 || session[:status]==4|| session[:status] ==111

    @account = Account.new
    end
  end

  def create
    @account = Account.new(params[:account])
    if @account.save
      flash[:notice] = 'Создан новый счет.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    if session[:status]==2 || session[:status]==3 || session[:status]==4 || session[:status] ==111
      @account = Account.find(params[:id])
    end
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:notice] = 'Счет обновлен.'
      redirect_to :action => 'show', :id => @account
    else
      render :action => 'edit'
    end
  end

#  def destroy
#    Account.find(params[:id]).destroy
#    redirect_to :action => 'list'
#  end
end
