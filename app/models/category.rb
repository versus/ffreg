class Category < ActiveRecord::Base
  acts_as_tree

  validates_presence_of :name, :parent_id
 before_validation :prepare_parent_id

 def prepare_parent_id
   if self.parent_id.nil?
     self.parent_id = 0
   end
  end

has_many :grand
has_many :payments

end
