class AcceptsController < ApplicationController
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  def add
    @accept = Accept.new()
    @accept.comment=params[:comment]
    @accept.payment_id = params[:payment_id]
    @accept.create_at=Time.now
    @accept.user_id = session[:user]
    if @accept.save
    @payment = Payment.find(:first, :conditions =>["id=?", params[:payment_id]])
    @payment.status = 1
    @payment.create_at=Time.now
    if @payment.save
    @flash[:notice] = 'Документ подписан'
    delevents=Event.find(:all, :conditions =>["payment_id=? and status=0",@payment.id])
    unless delevents.nil?
    delevents.each {|ev|
    ev.status=1
    ev.save
    }
    end
    event=Event.new
    event.create_at=Time.now
    event.status=0
    event.payment_id=@payment.id
    event.subject="Заявка <a href='/payments/poisk/"+@payment.id.to_s+"'>#"+@payment.id.to_s+"</a> подписана"
    event.user_from=session[:user]
    event.user_to=@payment.user.id
    event.save
    redirect_to(:action => 'list', :controller => 'payments')    
    else
       render :inline => "Ошибка сохранения паймента"
    end
    else
      render :text => 'Ошибка создания подписи'
    end
  end

  def list
    @accept_pages, @accepts = paginate :accepts, :per_page => 10
  end

  #def show
  #  @accept = Accept.find(params[:id])
  #end

  def new
    @accept = Accept.new
  end

  def create
    @accept = Accept.new(params[:accept])
    if @accept.save
      flash[:notice] = 'Accept was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  #def edit
  #  @accept = Accept.find(params[:id])
  #end

  #def update
  #  @accept = Accept.find(params[:id])
  #  if @accept.update_attributes(params[:accept])
  #    flash[:notice] = 'Accept was successfully updated.'
  #    redirect_to :action => 'show', :id => @accept
  #  else
  #    render :action => 'edit'
  #  end
  #end

  #def destroy
  #  Accept.find(params[:id]).destroy
  #  redirect_to :action => 'list'
  #end
end
