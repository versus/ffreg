class CurrenciesValuesController < ApplicationController
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
    @NGRN = CurrenciesValue.find(:first, :include => [:currency], :conditions => ['currencies.abbr=?', 'NGRN'], :order => ' create_at DESC')
    @BNGRN = CurrenciesValue.find(:first, :include => [:currency], :conditions => ['currencies.abbr=?', 'BNGRN'], :order => ' create_at DESC')
  end

  def history
    @currencies_value_pages, @currencies_values = paginate :currencies_values, :per_page => 50, :order => 'create_at DESC'
  end

  def show
    @currencies_value = CurrenciesValue.find(params[:id])
  end

  def new
    @currencies_value = CurrenciesValue.new
  end

  def create
    @currencies_value = CurrenciesValue.new(params[:currencies_value])
    @currencies_value.create_at = Time.now
    if @currencies_value.currency_id.nil?
      @currencies_value.currency = Currency.find(:first, :conditions => ["abbr=?", 'USD'])
    end
    
    if @currencies_value.loss.nil? ||  @currencies_value.loss==0
      @currencies_value.loss = 1
    end

    if @currencies_value.crossrate.nil? ||  @currencies_value.crossrate==0
      @currencies_value.crossrate = 1
    end


    if @currencies_value.save
      flash[:notice] = 'Создан новый курс обмена валюты'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end



#  def destroy
#    CurrenciesValue.find(params[:id]).destroy
#    redirect_to :action => 'list'
#  end
end
