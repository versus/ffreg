class Firm < ActiveRecord::Base
  acts_as_tree

  validates_presence_of :name,:phone
  validates_format_of :phone,
                      :with => /^\+?\s?\d{6,13}/,
                      :message => "Должен быть цифровым!"

  validates_length_of :name, :minimum => 3, :message => "Не меньше 3-х символов!"

  has_many :users
  has_many :accounts
  has_many :payments
  has_many :budgets
end
