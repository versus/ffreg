class PaymentsController < ApplicationController
  layout :writers_and_readers
  before_filter :check_authentication
  auto_complete_for :payment, :contragent

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }


  private
      
  def writers_and_readers
    unless params[:printer]==nil 
      "payments" 
    else 
      "index" 
    end
  end


  public
  
  def index
    list
    render :action => 'list'
  end



  def open_plan
    @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    
    if session[:year].nil? ==true
      year = Time.now.strftime("%Y")
      session[:year] = year
    else  
      year=session[:year]
    end
  
    firm_id=session[:firm]

    if session[:month].nil? ==true
       session[:month]=@mounths[Time.now.strftime("%m").to_i]
    end

    budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=?", session[:month], session[:year], session[:firm]])
    @can_add_payment = 0
    if budget.status == "подготовка"
      @can_add_payment = 1
    elsif budget.status == "защита"
      @can_add_payment = 2
    elsif budget.status == "утверждено"
      @can_add_payment = 3
    end
    
    @categories = Category.find(:all, :conditions => ["parent_id=0"])

    @persone=User.find(session[:user])
    @payments=Payment.find(:all, :conditions=>["planned=1 AND year=? AND month=? AND firm_id=? AND category_id=? AND status=?", session[:year],session[:month], session[:firm], params[:cat_id], "999999"])

    unless @payments.empty? == false
      render :text => "Плановых заявок за "+session[:month].to_s+" "+session[:year].to_s+" в данной категории нет!"
    end

    @ngrn_summ=Payment.sum(:summ, :conditions => ["planned=1 AND status=? AND firm_id=? AND currency_id=? AND category_id=?  AND month = ? AND year=? " ,"999999",firm_id, Currency.find_by_abbr('NGRN'), params[:cat_id], session[:month], session[:year]])

    @bngrn_summ=Payment.sum(:summ, :conditions => ["planned=1 AND status=? AND firm_id=? AND currency_id=? AND category_id=?  AND month = ? AND year=? " ,"999999",firm_id, Currency.find_by_abbr('BNGRN'), params[:cat_id], session[:month], session[:year]])

    @usd_summ=Payment.sum(:summ, :conditions => ["planned=1 AND status=? AND firm_id=? AND currency_id=? AND category_id=?  AND month = ? AND year=?  " ,"999999",firm_id, Currency.find_by_abbr('USD'), params[:cat_id], session[:month], session[:year]])

    @ngrn_summ=0 if @ngrn_summ.nil?
    @bngrn_summ=0 if @bngrn_summ.nil?
    @usd_summ=0 if @usd_summ.nil?
  end

  def pay_new_as_old
  #создание новой заявки на основе старой
    @persone=User.find(session[:user])
    unless params[:id]==nil
      payment_old=Payment.find(params[:id])
      payment_new=payment_old.clone
      payment_new.create_at = Time.now
      payment_new.close_at = nil
      payment_new.status=10000
      payment_new.user=@persone

      if payment_new.save
        session[:razdel]=10000
        flash[:notice] = 'Заявка создана!'
      else
        flash[:error] = 'Ошибка создания заявки!' 
      end
    else
      flash[:error] = 'Ошибка передачи данных!'  
    end
    redirect_to :action => "list"
  end

  def transfer
    @payment = Payment.new(params[:payment])

    @payment.create_at = Time.now
    @payment.category_id=Category.find_by_name('Трансфер').id
    @payment.close_at = nil
    @payment.title = "<span style='color:red'>Трансфер:</span> " + params[:payment][:title]
    @payment.status = 10000 # черновик
    @payment.firm = Firm.find(:first, :conditions => ["id=?", session[:firm]])
    @payment.user = User.find(:first, :conditions => ["id=?", session[:user]])

    if @payment.save
      flash[:notice] = 'Заявка создана!'
    else
      flash[:error] = 'Ошибка создания заявки!'     
    end

    redirect_to :action => "list"
  end

  def poisk    
    unless params[:id]==nil
      begin
        @payments=Payment.find(params[:id])
      rescue
        flash[:error] = "Такого номера в базе нет!"
        @payments=nil
      end
     
      if @payments.nil? == false
        @persone=User.find(session[:user])
        if @persone.has_role?('roles.admin') || @persone.has_role?('roles.chiff') || @payments.user.id==session[:user]
          @categories = Category.find(:all, :conditions => ["parent_id=0"])
        else
          render :text => "тут рыбы нет!"
        end
      else
        flash[:error] = "Такого номера в базе нет!"
        redirect_to :action => :list
      end
   else
     render :text => "Ошибка передачи параметров!"
   end
 end

 def printer
   @persone=User.find(session[:user])

   if @persone.has_role?('view.firms')
     firm_id=session[:firm]
   else
     firm_id=@persone.firm.id
   end

   yy,mm=params[:year].to_i,params[:month].to_i
   
   @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]

   @mow =  @mounths[mm]
   @year=yy
   @month=mm
   @firm=Firm.find_by_id(firm_id)

   current_mon = Time.local(yy,mm,1)
   mm_next,yy_next = 0,0
   
   if mm == 12
      mm_next =1
      yy_next=yy+1
    else
      mm_next=mm+1
      yy_next=yy
    end
    
    next_mon=Time.local(yy_next,mm_next,1)

    if session[:razdel]==2
      order='close_at DESC'
    else
      order='create_at DESC'
    end

    if @persone.has_role?('view.payments.all')
      @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=? AND create_at > ? AND create_at < ? ",session[:razdel],params[:firm], current_mon, next_mon] , :order => order)
    elsif   @persone.has_role?('view.payments.sklad')
    #закупки видны только фрегат и только безнал и только центральные закупки
      beznal_id=Currency.find(:first, :conditions =>["abbr=?", 'BNGRN']).id
      category_zakupka=Category.find_by_name("Централизованная закупка")
      firm_fregat_id = Firm.find_by_name("Фрегат")
      @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=? AND currency_id=? AND category_id=? AND create_at > ? AND create_at < ? ",session[:razdel],firm_fregat_id, beznal_id, category_zakupka, current_mon, next_mon ] , :order => order)
      @payadd =Payment.find(:all, :conditions =>["status=? AND firm_id=?  AND user_id=? AND create_at > ? AND create_at < ? ",session[:razdel],firm_id, session[:user], current_mon, next_mon] , :order => order)

    elsif @persone.has_role?('view.payments.beznal')
      beznal_id=Currency.find(:first, :conditions =>["abbr=?", 'BNGRN']).id
      @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=? AND currency_id=? AND create_at > ? AND create_at < ? ",session[:razdel],params[:firm], beznal_id, current_mon, next_mon ] , :order => order)
      @payadd = Payment.find(:all, :conditions =>["status=? AND firm_id=? AND currency_out=? AND currency_id!=? AND create_at > ? AND create_at < ? ", session[:razdel],params[:firm], beznal_id,beznal_id, current_mon, next_mon ], :order => order)

    else
      @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=?  AND user_id=? AND create_at > ? AND create_at < ? ",session[:razdel],firm_id, session[:user], current_mon, next_mon] , :order => order)

    end
  end

  def editpay
    @persone=User.find(session[:user])
    unless params[:id]==nil
      @payment=Payment.find(params[:id])
      if @payment.user.id==session[:user]
        @categories = Category.find(:all, :conditions => ["parent_id=0"])
      elsif  @persone.has_role?('roles.admin')
        @categories = Category.find(:all, :conditions => ["parent_id=0"])
      else
        render :text => "Ошибка авторства"
      end
    else
      render :text => "Ошибка передачи параметров"
    end
  end

  def accept_back
  #Возврат ошибочно подписанной заявки 
    if params[:id]==nil or params[:comment]==nil
      flash[:error] = "Ошибка передачи параметров"
    else  
      payment = Payment.find_by_id(params[:id])
      @persone=User.find(session[:user])
      payment.comment = params[:comment] 
      payment.title="<span style='color:red'>Возврат:</span> "+payment.title
      payment.status = 0
      
      if payment.save
        flash[:notice] = 'Подпись аннулирована!'
        event=Event.new
        event.create_at=Time.now
        event.status=0
        event.subject="Подпись заявки <a href='/payments/poisk/"+payment.id.to_s+"'>#"+payment.id.to_s+"</a> отменена"
        event.user_from=session[:user]
        event.user_to=payment.user.id
        event.payment_id=payment.id
        event.save
    #event начальнику
        event=Event.new
        event.create_at=Time.now
        event.status=0
        event.subject="Подпись заявки <a href='/payments/poisk/"+payment.id.to_s+"'>#"+payment.id.to_s+"</a> отменена"
        event.user_from=session[:user]
        event.payment_id=payment.id
        event.user_to=Firm.find_by_name('Фрегат').users.find_by_parent_id(0)
        event.save
      else
        flash[:error] = "Ошибка сохранения параметров"
      end
    end
    redirect_to :action => "list"
  end

  def pay_recovery
  #Возврат ошибочно проведенной заявки
    @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    payment = Payment.find(:first, :conditions=>["id=?", params[:id]])
    payment.status=1
    payment.save
    acc = Account.find(:first, :conditions =>["firm_id=? and currency_id=?", payment.firm_id, payment.currency_id])
    grand = Grand.find(:first, :conditions => {:firm_id => payment.firm_id,:year => payment.close_at.year, :mounth => @mounths[payment.close_at.mon], :category_id => payment.category_id}) 
    buff=acc.summ+payment.summ
    acc.summ=buff
    acc.save    
    
    if payment.currency.abbr =='USD' 
      summ_in_USD=payment.summ
    elsif payment.currency.abbr =='BNGRN'
      summ_in_USD=payment.summ/payment.currency.currencies_values.find(:first, :order=>'create_at DESC').crossrate*payment.currency.currencies_values.find(:first, :order=>'create_at DESC').loss
    elsif payment.currency.abbr =='NGRN'
      summ_in_USD=payment.summ/payment.currency.currencies_values.find(:first, :order=>'create_at DESC').crossrate
    else
      summ_in_USD=0;
    end   
      summ_in_USD=(summ_in_USD*100).ceil.to_f/100;
      tmp_grand=grand.fact
      grand.fact=tmp_grand-summ_in_USD
      grand.save
            
      redirect_to :action => "list"
  end

  def list
    @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    @persone=User.find(session[:user])

    if @persone.has_role?('view.firms')
      if params[:firm]==nil
        firm_id=session[:firm]
      else
        firm_id=params[:firm]
        session[:firm]=firm_id
      end
    else
      firm_id=session[:firm]
    end

# старый код
    if params[:year].nil? 
      if session[:year].nil?
        yy=Time.now.strftime("%Y").to_i
      else
        yy = session[:year]
      end
    else 
      yy = params[:year].to_i
      mm=1
    end

    unless params[:limits].nil?
      limits = params[:limits]
    else
      limits = nil
    end

        
    if params[:month].nil?
      if session[:mmonth].nil?
        mm=Time.now.month
      else
        mm=session[:mmonth].to_i
      end

    elsif params[:month]=="0"
      mm=0
    else 
      mm=params[:month].to_i
    end

    session[:year] = yy
    session[:mmonth] = mm
    @mow = @mounths[mm]

    begin
      current_mon = Time.local(yy,mm,1)
    rescue
      current_mon = Time.now
    end
#конец старого кода
  
    if mm == 12
      mm_next =1
      yy_next=yy+1
    else
      mm_next=mm+1
      yy_next=yy
    end

    begin
      next_mon=Time.local(yy_next,mm_next,1)
    rescue
      next_mon=Time.now
    end

    @year=yy
    @month=mm
    
    unless params[:order]==nil
     order = order_close='' << params[:order] << ' DESC'
   else
	   order='prio DESC'
   end

   if session[:razdel]==nil  
     session[:razdel]=1
   end
    
   unless params[:razdel]==nil
     session[:razdel]=params[:razdel]
   end
               
   @categories = Category.find(:all, :conditions => ["parent_id=0"])
   @firm = Firm.find_by_id(firm_id)


   if @persone.has_role?('view.payments.all')
     if @persone.has_role?('roles.admin') || @persone.has_role?('roles.finotdel') 
       if session[:razdel]== 0
         @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=?",session[:razdel], firm_id] , :order => order, :limit => limits)
       else
         @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=? AND create_at > ? ",session[:razdel],firm_id, current_mon] , :order => order, :limit => limits)
       end
     elsif session[:razdel]== 10000 or  session[:razdel]== 15000 
       @payments =Payment.find(:all, :conditions =>["status=? AND user_id=? ",session[:razdel], session[:user]] , :order => order, :limit => limits)
     elsif session[:razdel]== 0
       @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=?",session[:razdel], firm_id] , :order => order, :limit => limits)
     else
       if session[:razdel]== 2
         @payments = Payment.find(:all, :conditions =>["status=? AND firm_id=? AND close_at > ? AND close_at < ? ",session[:razdel],firm_id, current_mon, next_mon] , :order => order, :limit => limits)
       else
         @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=? AND create_at > ? AND create_at < ? ",session[:razdel],firm_id, current_mon, next_mon] , :order => order, :limit => limits)
        end
      end

#elsif   @persone.has_role?('view.payments.sklad')
    #закупки видны только фрегат и только безнал и только центральные закупки
#    beznal_id=Currency.find(:first, :conditions =>["abbr=?", 'BNGRN']).id
#    category_zakupka=Category.find_by_name("Централизованная закупка")
#    firm_fregat_id = Firm.find_by_name("Фрегат")
#    @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=? AND currency_id=? AND category_id=? AND create_at > ? AND create_at < ? ",session[:razdel],firm_fregat_id, beznal_id, category_zakupka, current_mon, next_mon ] , :order => order)
#    @payadd =Payment.find(:all, :conditions =>["status=? AND firm_id=?  AND user_id=? AND create_at > ? AND create_at < ? ",session[:razdel],firm_id, session[:user], current_mon, next_mon] , :order => order)


    elsif @persone.has_role?('view.payments.beznal')

      beznal_id=Currency.find(:first, :conditions =>["abbr=?", 'BNGRN']).id
      beznalf_id=Currency.find(:first, :conditions =>["abbr=?", 'BNGRN_F']).id

      @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=? AND (currency_id=? OR currency_id=?) AND create_at > ? AND create_at < ? ",session[:razdel],firm_id, beznal_id, beznalf_id, current_mon, next_mon ] , :order => order, :limit => limits)
      
      @payadd = Payment.find(:all, :conditions =>["status=? AND firm_id=? AND currency_out=? AND (currency_id!=? OR currency_id!=?) AND create_at > ? AND create_at < ? ", session[:razdel],firm_id, beznal_id, beznalf_id, beznal_id, current_mon, next_mon ], :order => order, :limit => limits)
      
      @payuser =Payment.find(:all, :conditions =>["status=? AND user_id=? AND firm_id=? AND create_at > ? AND (currency_id!=? OR currency_id!=?)",session[:razdel], session[:user], firm_id, current_mon, beznal_id, beznalf_id] , :order => order, :limit => limits)

    else
      if session[:razdel] == 12000
        budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=?", session[:month], session[:year], session[:firm]])
        if budget.status == "утверждено"
  @payments=Payment.find(:all, :conditions=>["planned=1 AND year=? AND month=? AND firm_id=? AND category_id=? AND status=?", session[:year],session[:month], session[:firm], params[:cat_id], "999999"])
        end

      elsif  session[:razdel]== 10000 or  session[:razdel]== 15000 
        if @persone.has_role?('roles.partner')
          @payments =Payment.find(:all, :conditions =>["status=? AND firm_id=? ",session[:razdel], firm_id] , :order => order, :limit => limits)
        else
           @payments =Payment.find(:all, :conditions =>["status=? AND user_id=? ",session[:razdel], session[:user]] , :order => order, :limit => limits)
        end
      else
        @payments = Payment.find(:all, :conditions =>["status=? AND firm_id=?  AND user_id=? AND create_at > ? AND create_at < ? ",session[:razdel],firm_id, session[:user], current_mon, next_mon] , :order => order, :limit => limits)
      end
    end

    if @persone.has_role?('view.payments.all')==true
      @ngrn_summ = Payment.sum(:summ, :conditions => ["status=? AND firm_id=? AND currency_id=? AND create_at > ? " ,session[:razdel],firm_id, Currency.find_by_abbr('NGRN'), current_mon], :limit => limits)
      @bngrn_summ=Payment.sum(:summ, :conditions => ["status=? AND firm_id=? AND currency_id=? AND create_at > ?" ,session[:razdel],firm_id, Currency.find_by_abbr('BNGRN'), current_mon], :limit => limits)
      @bngrnf_summ=Payment.sum(:summ, :conditions => ["status=? AND firm_id=? AND currency_id=? AND create_at > ?" ,session[:razdel],firm_id, Currency.find_by_abbr('BNGRN_F'), current_mon], :limit => limits)
      @usd_summ=Payment.sum(:summ, :conditions => ["status=? AND firm_id=? AND currency_id=? AND create_at > ? " ,session[:razdel],firm_id, Currency.find_by_abbr('USD'), current_mon], :limit => limits)
    else
      @ngrn_summ = Payment.sum(:summ, :conditions => ["status=? AND firm_id=? AND currency_id=?  AND user_id=? AND create_at > ?" ,session[:razdel],firm_id, Currency.find_by_abbr('NGRN'), session[:user], current_mon], :limit => limits)
      @bngrn_summ = Payment.sum(:summ, :conditions => ["status=? AND firm_id=? AND currency_id=?  AND user_id=? AND create_at > ? " ,session[:razdel],firm_id, Currency.find_by_abbr('BNGRN'), session[:user], current_mon], :limit => limits)
      @bngrnf_summ=Payment.sum(:summ, :conditions => ["status=? AND firm_id=? AND currency_id=?  AND user_id=? AND create_at > ? " ,session[:razdel],firm_id, Currency.find_by_abbr('BNGRN_F'), session[:user], current_mon], :limit => limits)

      @usd_summ=Payment.sum(:summ, :conditions => ["status=? AND firm_id=? AND currency_id=?  AND user_id=? AND create_at > ? " ,session[:razdel],firm_id, Currency.find_by_abbr('USD'), session[:user], current_mon], :limit => limits)

    end

    @ngrn_summ=0 if @ngrn_summ== nil
    @bngrn_summ=0 if @bngrn_summ== nil
    @usd_summ=0 if @usd_summ== nil
    @bngrnf_summ=0 if @bngrnf_summ== nil
end

  def trash
    @payment = Payment.find(:first, :conditions=>["id=?", params[:id]])
    
    if @payment.user.id==session[:user]
      @payment.status=666
      @payment.close_at=Time.now
      
      if @payment.save
        flash[:notice] = "Заявка удалена!"
      end
    else
      flash[:error] = "Вы не являетесь создателем заявки!"
    end      

    redirect_to :action => 'index'
  end

  def trash_plan
    budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=?", session[:month], session[:year], session[:firm]])
    persone=User.find(session[:user])
    @payment = Payment.find(:first, :conditions=>["id=?", params[:id]])
    if @payment.user.id==session[:user]
      if budget.status ==  "подготовка"
        @payment.status=8888
        @payment.close_at=Time.now
        if @payment.save
          flash[:notice] = "Заявка удалена!"
        end
      elsif persone.has_role?('roles.chiff')
        @payment.status=8888
        @payment.save
        flash[:notice] = "Заявка удалена!"
      else
        flash[:error] ="Бюджет закрыт для удаления заявок"
      end
    else
      flash[:error] = "Вы не являетесь создателем заявки!"
    end      
  
    redirect_to :action => 'showbudget', :controller => 'grands'
  end

  def chernovik
    @payment = Payment.find(:first, :conditions=>["id=?", params[:id]])
    @persone=User.find(session[:user])

    if @persone.has_role?('roles.partner')
      @payment.status=15000
      @payment.create_at = Time.now
      
      if @payment.save
        flash[:notice] = 'Заявка перемещена в общие документы!'
      else
        flash[:error] = 'Заявка не может быть изменена!'
      end
    else
      if @payment.user.login==session[:name] 
        @payment.status=10000
        @payment.create_at = Time.now
        if @payment.save
          flash[:notice] = 'Заявка перемещена в черновик!'
        else
          flash[:error] = 'Заявка не может быть изменена!'
        end
      end
    end

    redirect_to :action => 'list'
  end

  def foraccept
  #первод заявки на подпись руководителю
    @payment = Payment.find(:first, :conditions=>["id=?", params[:id]])
    @payment.status=0
    @payment.create_at = Time.now
    
    if @payment.save
       flash[:notice] = 'Заявка перенесена на подпись руководителю!'
       event=Event.new
       event.payment_id=@payment.id
       event.create_at=Time.now
       event.status=0
       event.subject="Добавлена завка <a href='/payments/poisk/"+@payment.id.to_s+"'>#"+@payment.id.to_s+"</a> на подпись от фирмы "+@payment.firm.name
       event.user_from=session[:user]
       director=Firm.find_by_name('Фрегат')
       event.user_to=director.users.find_by_parent_id(0).id
       event.save
    else
      flash[:error] = 'Заявка не может быть изменена!'
    end    
    redirect_to :action => 'list'
  end


  def payclose
    #закрытие заявки в бухгалтерии или финотделе
    flag=0
    @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    mm=Time.now.strftime("%m").to_i
    yy=Time.now.strftime("%Y").to_i
    current_mon = Time.local(yy,mm,1)
    mow =  @mounths[mm]
    
    unless session[:status] == 3 || session[:status] == 2|| session[:status] == 4  || session[:status] == 111
      list
      render :action => 'list'
    end
    
    unless params[:payment_id].nil?
      pay_id=params[:payment_id]
    end
    
    unless params[:id].nil?
      pay_id=params[:id]
    end
    
    if (payment=Payment.find_by_id(pay_id))==nil
      render :text=>'не могу найти такую заявку!'
    end
    
    parent_firm=session[:firm]

    if payment.status=="1"
      acc = Account.find(:first, :conditions =>["firm_id=? and currency_id=?", payment.firm_id, payment.currency_id])
      grand = Grand.find(:first, :conditions => {:firm_id => payment.firm_id,:year => yy, :mounth => mow, :category_id => payment.category_id}) 

      if grand.nil?
        grand=Grand.new()
        grand.create_at= Time.now
        grand.plan=0
        grand.fact=0
        grand.year=yy
        grand.mounth=mow
        grand.category_id=payment.category.id
        grand.firm_id=payment.firm_id
        grand.accept=0
        grand.save!
        grand.reload
      end

      buff=acc.summ-payment.summ
      acc.summ=buff
      acc.save    
      
      if payment.currency.abbr =='USD' 
        summ_in_USD=payment.summ
      elsif payment.currency.abbr =='BNGRN_F'
        summ_in_USD=payment.summ/payment.currency.currencies_values.find(:first, :order=>'create_at DESC').crossrate*payment.currency.currencies_values.find(:first, :order=>'create_at DESC').loss
      elsif payment.currency.abbr =='BNGRN'
        summ_in_USD=payment.summ/payment.currency.currencies_values.find(:first, :order=>'create_at DESC').crossrate*payment.currency.currencies_values.find(:first, :order=>'create_at DESC').loss
      elsif payment.currency.abbr =='NGRN'
        summ_in_USD=payment.summ/payment.currency.currencies_values.find(:first, :order=>'create_at DESC').crossrate
      else
        summ_in_USD=0;
      end   
      
      summ_in_USD=(summ_in_USD*100).ceil.to_f/100;
            
      unless grand.fact.nil? ==true
        tmp_grand=grand.fact
      else
        grand.fact=0
        grand.save
        tmp_grand = 0  
      end

      grand.fact=tmp_grand+summ_in_USD
            
      unless grand.save
        msg = "Бюджетная статья не сохранилась"
        flag = 1
      end
            
      payment.status=2
      payment.close_at=Time.now
      
      unless payment.save
        msg = "Заявка не сохраниась"
        flag = 1
      end
            
    else
      msg = "не подписано!"
      flag=1
    end

    if flag==0
      msg ="Заявка проведена!"
    end
      
    flash[:notice] = msg
    redirect_to :action => :list
  end

  def paycloseback
    unless session[:status] == 3 || session[:status] == 2 || session[:status] ==111|| session[:status] == 4
      list
      render :action => 'list'
    end
    
    @payment = Payment.find(:first, :conditions=>["id=?", params[:payment_id]])
    @payment.status = 1
    @payment.create_at = Time.now
    
    if @payment.save
      flash[:notice] = 'Заявка перемещена в черновик!'
    else
      flash[:error] = 'Заявка не может быть изменена!'
    end

    if session[:status] ==111
      redir = :finotdel
    elsif session[:status] == 4
      redir = :beznal
    elsif session[:status] == 2
      redir = :chiff
    end
    
    redirect_to :action => redir
  end

  def cat_change
  #В заявке изменилась категория расхода 
    unless session[:status] == 3 || session[:status] == 2
      list
      render :action => 'list'
    end
    
    @payment = Payment.find(:first, :conditions=>["id=?", params[:payment_id]])
    @payment.category_id=params[:cat_id]
    
    if @payment.save
      render :inline => 'Категория заявки обновлена!'
      event=Event.new
      event.create_at=Time.now
      event.status=0    
      event.payment_id=@payment.id
      event.subject="В заявке <a href='/payments/poisk/"+@payment.id.to_s+"'>#"+@payment.id.to_s+"</a> изменена категория"
      event.user_from=session[:user]
      event.user_to=@payment.user.id
      event.save
    else
      render :inline => 'Заявка не может быть изменена!'
    end
  end
  
  def change_summ
    #В заявке изменилась сумма расхода 
    unless session[:status] == 3 || session[:status] == 2
      list
      render :action => 'list'
    end
    @payment = Payment.find(:first, :conditions=>["id=?", params[:payment_id]])
    summ=params[:summ].to_s
    summ=summ.gsub(/,/, ".")
    summ=summ.gsub(/ю/, ".")
    summ=summ.gsub(/\s/, "")
    summ=sprintf( "%.2f", summ).to_f
    
    @payment.summ=summ
    @payment.currency_id=params[:currency_id]

    if @payment.save
      render :inline => 'Сумма заявки обновлена!'
      event=Event.new
      event.create_at=Time.now
      event.status=0    
      event.payment_id=@payment.id
      event.subject="В заявке <a href='/payments/poisk/"+@payment.id.to_s+"'>#"+@payment.id.to_s+"</a> изменена сумма"
      event.user_from=session[:user]
      event.user_to=@payment.user.id
      event.save
    end
  end

  def payment_cancel
    payment = Payment.find(:first, :conditions=>["id=?", params[:payment_id]])
    payment.status=0
    payment.create_at = Time.now
    #payment.close_at = Time.now

    accepts = Accept.find(:all, :conditions => ["payment_id=?", params[:payment_id] ])

    for accept in accepts
      if accept.comment.nil?
        accept.comment = ""
      end
      accept.comment =  '<span style="color:red">Подпись отменена</span>'
      accept.save
    end

    if payment.save
      flash[:notice] = "Подпись отменена"
    else
      flash[:error] = "Подпись не отменена!"
    end
    
    chiff
    redirect_to(:action => 'chiff')
  end

  def hold
      #Заявка была отклонена 
    @payment = Payment.find(:first, :conditions=>["id=?", params[:payment_id]])
    if @payment.nil?
        render :inline => "ID Заявки нет! ${params[:id]}"
    end
    
    @payment.status=3
    @payment.close_at = Time.now

    if @payment.comment == nil
      @payment.comment=''
    end

    unless params[:comment] == nil
      @payment.comment = @payment.comment << "<hr><br>Причина отказа:<br>" << params[:comment] 
    end
    
    if @payment.save
      msg = 'Заявка отклонена!'
      flash[:notice] = msg
      event=Event.new
      event.create_at=Time.now
      event.status=0
      event.payment_id=@payment.id
      event.subject="Заявка <a href='/payments/poisk/"+@payment.id.to_s+"'>#"+@payment.id.to_s+"</a> отклонена"
      event.user_from=session[:user]
      event.user_to=@payment.user.id
      event.save
      redirect_to :action => :list
    else
      
    end
    
  end


  def newpay
    @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    @year = Time.now.strftime("%Y")
    @categories = Category.find(:all, :conditions => ["parent_id=0"])
    firm_id=User.find(session[:user]).firm_id
    @firmw = Firm.find(:first, :conditions => ["id=?", firm_id])
    @mow = @mounths[Time.now.strftime("%m").to_i]
  end


  def new
    @payment = Payment.new
  end

  def new_grand   
    #создание плановой заявки 
     @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
     can_add_payment=false
     if session[:year].nil? ==true
       year = Time.now.strftime("%Y")
       session[:year] = year
     else  
       year=session[:year]
     end
  
     if session[:month].nil? ==true
       session[:month]=@mounths[Time.now.strftime("%m").to_i]
     end
    
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
       
       budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=?", month_tmp,year_tmp, session[:firm]])

       if budget.nil?
         newbudget=Budget.new()
         newbudget.month=month_tmp
         newbudget.year=year_tmp
         newbudget.status="подготовка"
         newbudget.firm_id=session[:firm]
         newbudget.save
         can_add_payment = true
       elsif budget.status == "подготовка"
         can_add_payment = true
       else
         flash[:error] = 'Ошибка отработки месячного бюджета, заявка не сохранена!'
         render :action => 'showbudget', :controller => :grands
       end

       if can_add_payment = true
         summ=params[:payment][:summ].to_s
         summ=summ.gsub(/,/, ".")
         summ=summ.gsub(/ю/, ".")
         summ=summ.gsub(/\s/, "")
         summ=sprintf( "%.2f", summ).to_f

         @payment = Payment.new(params[:payment])
         @payment.create_at = nil
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
   
    redirect_to :action => 'showbudget', :controller => :grands
  end
  

  def create
     @mounths = ["Весь год","Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    summ=params[:payment][:summ].to_s
    summ=summ.gsub(/,/, ".")
    summ=summ.gsub(/ю/, ".")
    summ=summ.gsub(/\s/, "")
    summ=sprintf( "%.2f", summ).to_f

    @payment = Payment.new(params[:payment])
    @payment.create_at = Time.now
    @payment.close_at = nil
    @payment.summ = summ
    @payment.status = 10000 # черновик

    uuu= User.find(:first, :conditions => ["id=?", session[:user]])
    @payment.firm_id = uuu.firm.id
    @payment.user_id = uuu.id

      if session[:year].nil?
        yy=Time.now.strftime("%Y").to_i
      else
        yy = session[:year]
      end
        mm=Time.now.month
        mow=@mounths[mm]
    
        if @payment.save

#      grand = Grand.find(:first, :conditions => {:firm_id => payment.firm_id,:year => yy, :mounth => mow, :category_id => payment.category_id}) 
#      if grand.nil?
#        grand=Grand.new()
#        grand.create_at= Time.now
#        grand.plan=0
#        grand.fact=0
#        grand.year=yy
#        grand.mounth=mow
#        grand.category_id=payment.category.id
#        grand.firm_id=payment.firm_id
#        grand.accept=0
#        grand.save!
#        grand.reload
#      end

      flash[:notice] = 'Заявка создана!'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end


	  

  def update
    @persone=User.find(session[:user]) 
    @payment = Payment.find(params[:id])
    
    if @payment.user.id==session[:user] || @persone.has_role?('roles.admin')
    
      if @payment.update_attributes(params[:payment])
        flash[:notice] = 'Заявка обновлена!'
      else
        flash[:error] = 'Ошибка сохранения заявки!'
      end
    
    else
      flash[:error] = 'Вы не являетесь автором заявки!'
    end

    redirect_to :action => 'list'

  end

end
