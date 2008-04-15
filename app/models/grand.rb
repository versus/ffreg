class Grand < ActiveRecord::Base
belongs_to :category
belongs_to :currency
has_many :payments

end


