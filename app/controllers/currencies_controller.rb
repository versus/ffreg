class CurrenciesController < ApplicationController
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
    @currency_pages, @currencies = paginate :currencies, :per_page => 10
  end

  def show
    @currency = Currency.find(params[:id])
  end

  def new
    @currency = Currency.new
  end

  def create
    @currency = Currency.new(params[:currency])
    if @currency.save
      flash[:notice] = 'Currency was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @currency = Currency.find(params[:id])
  end

  def update
    @currency = Currency.find(params[:id])
    if @currency.update_attributes(params[:currency])
      flash[:notice] = 'Currency was successfully updated.'
      redirect_to :action => 'show', :id => @currency
    else
      render :action => 'edit'
    end
  end

  def destroy
    Currency.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
