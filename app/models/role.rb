class Role < ActiveRecord::Base
#  has_many :users
  has_and_belongs_to_many :users
#  validates_presence_of :role
#  validates_uniqueness_of :role
end
