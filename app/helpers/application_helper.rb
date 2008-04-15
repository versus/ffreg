# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def display_categories(categories, parent_id)
    ret = "<ul  id='invoiceTotals'>" 
      for category in categories
        if category.parent_id == parent_id
          ret << display_category(category)
        end
      end
    ret << "</ul>" 
  end

  def display_category(category)
    ret = "<li>" 
    ret << link_to(h(category.name), :action => "show", :id => category)
    ret << display_categories(category.children, category.id) if category.children.any?
    ret << "</li>" 
  end

  def display_firms(firms, parent_id)
    ret = "<ul id='invoiceTotals'>" 
      for firm in firms
        if firm.parent_id == parent_id
          ret << display_firm(firm)
        end
      end
    ret << "</ul>" 
  end

  def display_firm(firm)
    ret = "<li>" 
    ret << link_to(h(firm.name), :action => "show", :id => firm)
    ret << display_firms(firm.children, firm.id) if firm.children.any?
    ret << "</li>" 
  end

  def print_budget(categories)
    ret = "" if ret.nil?
    for cc in categories
    if cc.typo == "1"
    ret << "<tr><td>"<<  cc.name << "</td></tr>"
   elsif cc.typo == "0"
    ret << "<tr><td>&nbsp;" << cc.name << "</td>"
  end 
  print_budget(cc.children) if cc.children.any?
     

  end
  end




end
