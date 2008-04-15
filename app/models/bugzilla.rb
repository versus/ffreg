class Bugzilla < ActiveRecord::Base
  validates_format_of   :user,
                        :with       => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                        :message    => 'Электронный ящик должен быть реальным'
 

end
