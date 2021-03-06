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

end
