module GrandsHelper
 def print_plan(cat_id, firm_id, month, year)
   ret = ""
    begin
    grand = Grand.find(:first, :conditions => {:category_id => cat_id, :firm_id => firm_id, :year => year, :mounth => month, :accept => false})
    ret << grand.plan.to_s 
    rescue
     ret << "0.0"
    end
 end
 def print_budget(cat_id, firm_id, month, year)
   statusbudgeta=["подготовка","на утверждение", "утвердить", "утверждено"]
   budget=Budget.find(:first, :conditions=>["month=? and year=? and firm_id=? and category_id=?",session[:month],session[:year], session[:firm], cat_id])

 if budget.nil?
   ret = "на утверждение"   
 else
   ret = budget.status
 end
 end
 def print_fact(cat_id, firm_id, month, year)
   ret = ""
    begin
    grand = Grand.find(:first, :conditions => {:category_id => cat_id, :firm_id => firm_id,  :year => year, :mounth => month, :accept => false})
    ret << grand.fact.to_s 
    rescue
     ret << "0.0"
    end
 end

 def print_plan_payments(cat_id, firm_id, month, year)
     ret =""
     begin
     summa=0
     pay=Payment.find(:all, :conditions=>[" planned=1 AND firm_id=? AND category_id=? AND year=? AND month=?", firm_id, cat_id, year, month])
     for i in pay
       summa=summa+i.summ
     end
     if summa == 0
     ret << "0.0"
     else
     ret << summa.to_s
     end
     rescue
     ret << "0.0"
     end
 end

def print_plan_summ(cat_id, firm_id, month, year)
   ret = ""
   summ = 0
    begin
    category = Category.find(cat_id)
    category.children.each {|ch|
    if ch.typo == "0"
      begin
      grand =  Grand.find(:first, :conditions => {:category_id => ch.id, :firm_id => firm_id, :year => year, :mounth => month, :accept => false})
      plan=grand.plan
      rescue
      plan=0
      end
      summ = summ + plan 
    end
    } 
    ret << summ.to_s
    rescue
     ret << "0.0"
    end
 end


end
