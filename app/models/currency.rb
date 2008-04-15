class Currency < ActiveRecord::Base
  validates_presence_of :name,:abbr

  has_many :currencies_values
  has_many :accounts
  has_many :grands
  has_many :payments
end
