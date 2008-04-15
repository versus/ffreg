class FirmsController < ApplicationController
  layout "index"
  before_filter :check_authentication


  def index
    list
    render :action => 'list'
  end


  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @firms = Firm.find(:all)
  end

  def show
    @firm = Firm.find(params[:id])
    @firms_name = Firm.find(:all, :select => :name)

  end

  def new
    @firm = Firm.new
  end

  def create
    @firm = Firm.new(params[:firm])
    if @firm.parent_id.nil?
          @firm.parent_id=0
    end

      
    if @firm.save
      flash[:notice] = 'Создана новая фирма.'

      ngrn = Account.new({"name"=>"NGRN", "summ"=>0})
      ngrn.currency = Currency.find(:first, :conditions => [ "abbr=?", "NGRN"] )
      @firm.accounts << ngrn
      bngrn = Account.new({"name"=>"BNGRN", "summ"=>0})
      bngrn.currency = Currency.find(:first, :conditions => [ "abbr=?", "BNGRN"] )
      @firm.accounts << bngrn
      usd = Account.new({"name"=>"USD", "summ"=>0})
      usd.currency = Currency.find(:first, :conditions => [ "abbr=?", "USD"] )
      @firm.accounts << usd
        if @firm.save
            redirect_to :action => 'list'
        else
            flash[:error] = 'Проблема с созданием счетов фирмы'
            render :action => 'new'

        end
    else
      render :action => 'new'
    end
  end

  def edit
    @firm = Firm.find(params[:id])
  end

  def update
    @firm = Firm.find(params[:id])
    if @firm.update_attributes(params[:firm])
      flash[:notice] = 'Firm was successfully updated.'
      redirect_to :action => 'show', :id => @firm
    else
      render :action => 'edit'
    end
  end

  def destroy
    Account.find(:all, :conditions => ["firm_id=?",params[:id]]).each { |acc| acc.destroy}
    User.find(:all, :conditions => ["firm_id=?",params[:id]]).each { |uss| 
      uss.firm=Firm.find(:first, :conditions => ["name=?", "OUT"])
    }
    a = Firm.find(params[:id])
    unless a.nodelete? 
      a.destroy
    end  
    redirect_to :action => 'list'
  end
end
