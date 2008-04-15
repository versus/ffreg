module PaymentsHelper
 def print_plan(cat_id, firm_id, month, year)
   ret = ""
    begin
    grand = Grand.find(:first, :conditions => {:category_id => cat_id, :firm_id => firm_id, :year => year, :mounth => month, :accept => false})
    ret << grand.plan.to_s 
    rescue
     ret << "0.0"
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
