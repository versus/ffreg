class Account < ActiveRecord::Base

  belongs_to :firm
  belongs_to :currency

  validates_presence_of :name, :summ, :firm_id, :currency_id

  validates_numericality_of :summ, :allow_nil => false, :message => "Балланс на счете это числовое значение!"


end
