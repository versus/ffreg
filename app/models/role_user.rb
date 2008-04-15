   class RolesUser < ActiveRecord::Base
     set_primary_key :not_id # int auto_increment primary key, cannot be named 'id'
     belongs_to :role
     belongs_to :user
   end
