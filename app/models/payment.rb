class Payment < ActiveRecord::Base
  
  SORT_OPTIONS = [
      { :param => 'contragent_asc',     :order => 'contragent ASC'    },
      { :param => 'contragent_desc',    :order => 'contragent DESC'   },
      { :param => 'create_at_asc',      :order => 'create_at ASC'     },
      { :param => 'create_at_desc',     :order => 'create_at DESC'    },
      { :param => 'summ_asc',           :order => 'summ ASC'          },
      { :param => 'summ_desc',          :order => 'summ DESC'         },
      { :param => 'currency_asc',       :order => 'currency_id ASC'   },
      { :param => 'currency_desc',      :order => 'currency_id DESC'  }
    ]  

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
  
  def closed?
    self.status == 2
  end
  
  #
  def self.find_planned(start_month, end_month, order_by=SORT_OPTIONS.first[:order], limit_by=nil)
    find  :all, 
          :conditions => [ "status = 12000 AND create_at > ? AND create_at < ?" , start_month, end_month ],
          :order => order_from_param(order_by)
  end
  
  #
  def self.find_drafts
    find  :all, :conditions => [ "status = 10000" ]
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
  def self.find_signed(start_month, end_month, order_by=SORT_OPTIONS.first[:order], limit_by=nil)
    find  :all, 
          :conditions => [ "status = 1 AND create_at > ? AND create_at < ?" , start_month, end_month ],
          :order => order_from_param(order_by)
  end

  #
  def self.find_closed(start_month, end_month, order_by=SORT_OPTIONS.first[:order], limit_by=nil)
    find  :all, 
          :conditions => [ "status = 2 AND close_at > ? AND close_at < ?" , start_month, end_month ],
          :order => order_from_param(order_by)
  end
  
  #
  def self.find_rejected(start_month, end_month, order_by=SORT_OPTIONS.first[:order], limit_by=nil)
    find  :all, 
          :conditions => [ "status = 3 AND create_at > ? AND create_at < ?" , start_month, end_month ],
          :order => order_from_param(order_by)
  end

  #
  def self.find_planned_rejected(start_month, end_month, order_by=SORT_OPTIONS.first[:order], limit_by=nil)
    find  :all, 
          :conditions => [ "status = 8888 AND create_at > ? AND create_at < ?" , start_month, end_month ],
          :order => order_from_param(order_by)
  end
  
  #
  def self.find_deleted(start_month, end_month, order_by=SORT_OPTIONS.first[:order], limit_by=nil)
    find  :all, 
          :conditions => [ "status = 666 AND create_at > ? AND create_at < ?" , start_month, end_month ],
          :order => order_from_param(order_by)
  end
  
  def self.order_from_param( param )
    order = SORT_OPTIONS.detect do |option|
      option[:param] == param
    end
    
    order = SORT_OPTIONS.first if order.nil?
    order = order[:order]
  end

end
