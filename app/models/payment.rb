class Payment < ActiveRecord::Base
acts_as_tree
   
before_save :strip_HTML

   belongs_to :currency
   belongs_to :user
   belongs_to :category
   belongs_to :firm
   has_many :accepts

   validates_length_of :title, :minimum => 2, :to_short => 'Поле заголовка должно быть не менее 2 букв. '

  attr_accessor :recurring
 
  def to_USD(summ, abbr) 
    return summ=summ/5.05
  end

  def b_save
    #вызов strip_HTML
    #вызов reversumm
  end

  def reversumm
    # Если заяка имеет родителя и заявка имеет положительную сумму, тогда превращаем сумму в отрицательную.
  end

  def strip_HTML 
    begin
    self.title=self.title.gsub(/<\/?[^>]*>/, "")
    self.comment=self.comment.gsub(/<\/?[^>]*>/, "")
    self.contragent=self.contragent.gsub(/<\/?[^>]*>/, "")
    rescue

    end
  end
  
  #
  def self.find_planned(start_month, end_month, order_by=nil, limit_by=nil)
    find :all, :conditions => [ "status = 12000 AND create_at > ? AND create_at < ?" , start_month, end_month ]
  end
  
  #
  def self.find_drafts
    find :all, :conditions => [ "status = 10000" ]
  end
  
  #
  def self.find_shared
    find :all, :conditions => [ "status = 15000" ]
  end

  #
  def self.find_unsigned
    find :all, :conditions => [ "status = 0" ]
  end

  #
  def self.find_signed(start_month, end_month, order_by=nil, limit_by=nil)
    find :all, :conditions => [ "status = 1 AND create_at > ? AND create_at < ?" , start_month, end_month ]
  end

  #
  def self.find_closed(start_month, end_month, order_by=nil, limit_by=nil)
    find :all, :conditions => [ "status = 2 AND close_at > ? AND close_at < ?" , start_month, end_month ]
  end
  
  #
  def self.find_rejected(start_month, end_month, order_by=nil, limit_by=nil)
    find :all, :conditions => [ "status = 3 AND create_at > ? AND create_at < ?" , start_month, end_month ]
  end

  #
  def self.find_planned_rejected(start_month, end_month, order_by=nil, limit_by=nil)
    find :all, :conditions => [ "status = 8888 AND create_at > ? AND create_at < ?" , start_month, end_month ]
  end
  
  #
  def self.find_deleted(start_month, end_month, order_by=nil, limit_by=nil)
    find :all, :conditions => [ "status = 666 AND create_at > ? AND create_at < ?" , start_month, end_month ]
  end

end
