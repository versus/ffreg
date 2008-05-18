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
          #delparentsumm(grand.id, summm_old, @firmw.id)
          grand.plan=params[:summ]
          grand.create_at= Time.now
        end

    if grand.save
      flash[:notice] = 'Статья бюджета создана.'
      grand.reload
      ident=grand.id
      #addparentsumm(ident, grand.plan, @firmw.id)
    else
      flash[:error] = 'Ошибка создания.'
    end
    redirect_to :action => 'showbudget', :id => @firmw 
  end


  def new_grand   
    #создание плановой заявки 
     @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
     can_add_payment=false
     month_idx=@mounths.index(session[:month])
     if params[:payment][:recurring].to_i == 1
       count=3
     else
       count=1
     end
    
     for i in 1..count
       month_tmp=@mounths[month_idx]
       year_tmp=session[:year]
       
       if count >1
         if session[:mounth] == "Декабрь"
           if month_tmp == "Январь"
             year_tmp=year_tmp+1
           end
         end
       end
       cat_id=Category.find(params[:payment][:category_id]).parent.id
       budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=? and category_id=?", month_tmp,year_tmp, session[:firm], cat_id ])

       if budget.nil?
         newbudget=Budget.new()
         newbudget.month=month_tmp
         newbudget.year=year_tmp
         newbudget.status="подготовка"
         newbudget.firm_id=session[:firm]
         newbudget.category_id=params[:payment][:category_id]
         newbudget.save
         can_add_payment = true
       elsif budget.status == "подготовка"
         can_add_payment = true
       else
         flash[:error] = 'Ошибка отработки  бюджета, заявка не сохранена!'
       end

       if can_add_payment = true
         summ=params[:payment][:summ].to_s
         summ=summ.gsub(/,/, ".")
         summ=summ.gsub(/ю/, ".")
         summ=summ.gsub(/\s/, "")
         summ=sprintf( "%.2f", summ).to_f

         @payment = Payment.new(params[:payment])
         @payment.create_at = nil
         @payment.currency_id=3
         @payment.close_at = nil
         @payment.planned=true
         @payment.month = month_tmp
         @payment.year = year_tmp
         @payment.create_planned=Time.now
         @payment.summ = summ
         @payment.status = 999999 # плановая заявка
         
         uuu= User.find(:first, :conditions => ["id=?", session[:user]])
         
         @payment.firm_id = uuu.firm.id
         @payment.user_id = uuu.id

         if @payment.save
           flash[:notice] = 'Плановая заявка создана!'
         else
           flash[:error] = 'Ошибка сохранения заявки!'
         end
       end
  
       month_idx=month_idx+1
    end
   
    redirect_to   :action =>'showbudget'
  end
  def budget_down
    unless params["cat_id"].nil?
        persone=User.find(session[:user])
  if persone.has_role?('roles.chiff')
    budget= Budget.find(:first, :conditions=>["month=? and year=? and firm_id=? and category_id=?",session[:month],session[:year], session[:firm], params["cat_id"]])
    unless budget.nil?
      bzzz=Category.find(params["cat_id"])
       if budget.status=="на утверждении"
      flash[:notice] = "Бюджет по категории '#{bzzz.name}' переведен на подготовку!" 
          budget.status="подготовка"
       end
       budget.save
       redirect_to :action => 'showbudget'
    else
      render :text => "Такого бюджета нет!"
    end
  else
    render :text => "Тут рыбы нет!"
  end
    end
end

  def budget_ch_status
    unless params["cat_id"].nil?
        persone=User.find(session[:user])
  if persone.has_role?('roles.chiff')
    budget= Budget.find(:first, :conditions=>["month=? and year=? and firm_id=? and category_id=?",session[:month],session[:year], session[:firm], params["cat_id"]])
    unless budget.nil?
      bzzz=Category.find(params["cat_id"])
       if budget.status=="подготовка"
         budget.status="на утверждении"
      flash[:notice] = "Бюджет по категории '#{bzzz.name}' переведен в режим утверждения" 
       elsif budget.status=="на утверждении"
      flash[:notice] = "Бюджет по категории '#{bzzz.name}'  утвержден!" 
          budget.status="утверждено"
       end
       budget.save
       redirect_to :action => 'showbudget'
    else
      render :text => "Такого бюджета нет!"
    end
  else
    render :text => "Тут рыбы нет!"
  end
    end
end

  def game_again
  # функция переводит бюджет в подготовку
  # добавить категорию по которой бюджет

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

  def add_budget  
    # добавить категорию по которой бюджет

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
        unless params[:firm].nil? 
          session[:firm]=params[:firm]
        end
      end
   
      
      @firmw = Firm.find(:first, :conditions => ["id=?", session[:firm]])

      

 
    
      
    # разработать алгоритм утверждения бюджета по категориям
    
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
        render :text => 'Здесь рыбы нет!'

    #@grand = Grand.find(params[:id])
    #if @grand.update_attributes(params[:grand])
    #  flash[:notice] = 'Grand was successfully updated.'
    #  redirect_to :action => 'show', :id => @grand
    #else
    #  render :action => 'edit'
    #end
  end

  def destroy
    render :text => 'Здесь рыбы нет!'
    #Grand.find(params[:id]).destroy
    #redirect_to :action => 'list'
  end
end
