class GrandsController < ApplicationController

  layout "index"
  before_filter :check_authentication

 

def addparentsumm (id, summ, firm_id)
# добавляем сумму в родительскую категорию  
child=Grand.find(id)
unless child.category.parent.parent_id == 0
grand=Grand.find(:first, :conditions => ["year=? and mounth=? and category_id=? and firm_id=?", child.year,child.mounth, child.category.parent.id, firm_id])
  unless grand.nil? 
    grand.plan=grand.plan+summ
    grand.save
    addparentsumm(grand.id, summ, firm_id)
  else
          grand=Grand.new()
          grand.create_at= Time.now
          grand.plan=child.plan
          grand.fact=0
          grand.year=child.year
          grand.mounth=child.mounth
          grand.category_id=child.category.parent.id
          grand.firm_id=child.firm_id
          grand.accept=0
          grand.save
          addparentsumm(grand.id, summ, firm_id)
  end
end
 
end

#удаляем сумму изменившейся категории в бюджете из его родителей
def delparentsumm(id, summ, firm_id)
  child=Grand.find(id)
  unless child.category.parent.parent_id == 0
    grand=Grand.find(:first, :conditions => ["year=? and mounth=? and category_id=? AND firm_id=?", child.year,child.mounth, child.category.parent.id, firm_id])
    unless grand.nil?
      grand.plan=grand.plan-summ
      grand.save
      delparentsumm(grand.id, summ, firm_id)
    end
  end
end



  def index
  @persone=User.find(session[:user])
  if @persone.has_role?('view.firms')
     @firms = Firm.find(:all, :conditions =>["hidden=false"])
  else
     redirect_to :action => 'showbudget' 
  end
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    redirect_to :action => :index
  end

  def fullyear
   @mounths = ["Категория","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
      @persone=User.find(session[:user])

  if params[:firm].nil? == true
        if session[:firm_tmp].nil? == true
          session[:firm_tmp]=session[:firm]
          @firmw = Firm.find(:first, :conditions => ["id=?", session[:firm_tmp]])
        else
          @firmw = Firm.find(:first, :conditions => ["id=?", session[:firm_tmp]])
        end
      else
        session[:firm_tmp]=params[:firm]
        @firmw = Firm.find(:first, :conditions => ["id=?", params[:firm]])
      end



    if  params[:year].nil? == true && session[:year].nil? == false
      @year = session[:year]
   elsif params[:year].nil? 
      @year = Time.now.strftime("%Y")
    else 
      @year = params[:year]
    end
    session[:year] = @year
    @categories = Category.find(:all, :conditions => ["parent_id=0"])
  end

  def add
      @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]

    if params[:firm].nil? == true
      if session[:firm_tmp].nil? == true
        session[:firm_tmp]=session[:firm]
      end
      @firmw = Firm.find(:first, :conditions => ["id=?", session[:firm_tmp]])
    else
      session[:firm_tmp]=params[:firm]
      @firmw = Firm.find(:first, :conditions => ["id=?", params[:firm]])
    end
 
    if session[:year].nil? ==true
      year = Time.now.strftime("%Y")
    else  
      year=session[:year]
    end

    if session[:month].nil? ==true
       mow = @mounths[Time.now.strftime("%m").to_i]
    else  
      mow=session[:month]
    end

        grand = Grand.find(:first, :conditions => {:firm_id => @firmw.id,:year => year, :mounth => mow, :category_id => params[:id]}) 
        if grand.nil?
          grand=Grand.new()
          grand.create_at= Time.now
          grand.plan=params[:summ]
          grand.fact=0
          grand.year=year
          grand.mounth=mow
          grand.category_id=params[:id]
          grand.firm_id=@firmw.id
          grand.accept=0
        else
          summm_old=grand.plan
          delparentsumm(grand.id, summm_old, @firmw.id)
          grand.plan=params[:summ]
          grand.create_at= Time.now
        end

    if grand.save
      flash[:notice] = 'Статья бюджета создана.'
      grand.reload
      ident=grand.id
      addparentsumm(ident, grand.plan, @firmw.id)
    else
      flash[:error] = 'Ошибка создания.'
    end
    #redirect_to :action => 'showbudget', :id => @firmw 
  end

  def stoped
  # функция переводит бюджет в утверждаемый
    persone=User.find(session[:user])

    budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=?",session[:month],session[:year], session[:firm]])
    if budget.nil? == false and persone.has_role?('roles.chiff')
      budget.status="защита"
      budget.save
      flash[:notice] = "Бюджет переведен в режим утверждения" 
    else
      flash[:error] = "Ошибка! Такого бюджета нет!"
    end
    redirect_to :action => 'showbudget'
  end
  def game_again
  # функция переводит бюджет в подготовку
    persone=User.find(session[:user])
    budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=?",session[:month],session[:year], session[:firm]])
    if budget.nil? == false && persone.has_role?('roles.chiff')
      budget.status="подготовка"
      budget.save
      flash[:notice] = "Бюджет на доработке!" 
    else
      flash[:error] = "Ошибка! Такого бюджета нет!"
    end
    redirect_to :action => 'showbudget'

  end

  def game_over
  # функция переводит бюджет в утвержденный
    persone=User.find(session[:user])

    budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=?",session[:month],session[:year], session[:firm]])
    if budget.nil? == false && persone.has_role?('roles.chiff')
      budget.status="утверждено"
      budget.save
      flash[:notice] = "Бюджет утвержден!" 
    else
      flash[:error] = "Ошибка! Такого бюджета нет!"
    end
    redirect_to :action => 'showbudget'

  end

  def add_budget  
    @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    @year=session[:year] 
    @categories = Category.find(:all, :conditions => ["parent_id=0"])
    @firmw = Firm.find(:first, :conditions => ["id=?", session[:firm]])

  end

  def showbudget
    @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    @persone=User.find(session[:user])
   
    if params[:year].nil? == true
    if session[:year].nil? ==true
      @year = Time.now.strftime("%Y")
    else  
      @year=session[:year]
    end
    else
        @year = params[:year]
    end
    session[:year] = @year

  if params[:month].nil? == true
    if session[:month].nil? ==true
       @mow = @mounths[Time.now.strftime("%m").to_i]
    else  
      @mow=session[:month]
    end
  else
      @mow =  @mounths[params[:month].to_i]
  end
  session[:month]=@mow

      if @persone.has_role?('view.firms')
      if params[:firm].nil? == true
        if session[:firm_tmp].nil? == true
          session[:firm_tmp]=session[:firm]
          @firmw = Firm.find(:first, :conditions => ["id=?", session[:firm_tmp]])
        else
          @firmw = Firm.find(:first, :conditions => ["id=?", session[:firm_tmp]])
        end
      else
        session[:firm_tmp]=params[:firm]
        session[:firm]=params[:firm]
        @firmw = Firm.find(:first, :conditions => ["id=?", params[:firm]])
      end
    else
      @firmw = Firm.find(:first, :conditions => ["id=?", session[:firm]])
    end
 
    budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=?", session[:month], session[:year], session[:firm]])
    @can_add_payment = 0
    if budget.nil? == true
      newbudget=Budget.new()
      newbudget.month=session[:month]
      newbudget.year=session[:year]
      newbudget.status="подготовка"
      if session[:firm].nil? == true
        session[:firm]=@persone.firm.id
      end
      newbudget.firm_id=session[:firm]
      newbudget.save
      @can_add_payment = 1
    elsif budget.status == "подготовка"
      @can_add_payment = 1
    elsif budget.status == "защита"
      @can_add_payment = 2
    elsif budget.status == "утверждено"
      @can_add_payment = 3
    end



    @categories = Category.find(:all, :conditions => ["parent_id=0"])
    begin
      if @mov == 0
       @grands = Grand.find(:all,  :conditions => {:firm_id => @firmw.id, :year => @year,  :accept => false})
       @error =false
      else
       @grands = Grand.find(:all, :conditions => {:firm_id => @firmw.id,:year => @year, :mounth => @mow, :accept => false})
       @error = false
      end
    rescue
     @error = true
    end
  end

  def show
    @grand = Grand.find(params[:id])
  end

  def new
    @grand = Grand.new
    @categories=Category.find(:all, :conditions =>["typo=?", 0] ,:order => 'parent_id ASC')
  end

  def create
    @grand = Grand.new(params[:grand])
    @grand.create_at = Time.now
    @grand.fact = 0
    @grand.currency = Currency.find(:first, :conditions => ["abbr=?", "USD"])
    @grand.accept=false
    if @grand.save

      flash[:notice] = 'Статья бюджета создана.'
      redirect_to :action => 'showbudget'
    else
      render :action => 'new'
    end
  end

  def edit
    @grand = Grand.find(params[:id])
    @categories=Category.find(:all, :conditions =>["typo=?", 0] ,:order => 'parent_id ASC')

  end

  def update
    @grand = Grand.find(params[:id])
    if @grand.update_attributes(params[:grand])
      flash[:notice] = 'Grand was successfully updated.'
      redirect_to :action => 'show', :id => @grand
    else
      render :action => 'edit'
    end
  end

  def destroy
    Grand.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
