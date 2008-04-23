#TODO replace with restful_authentication
class User < ActiveRecord::Base
  belongs_to :firm
  has_many :payments
  has_many :accepts
  #has_many :roles
  has_and_belongs_to_many :roles
  acts_as_tree

  attr_accessor :password, :password_confirmation
  before_save :prepare_password

    def has_role?(role)
      self.roles.count(:conditions => ['ident = ?', role]) > 0
    end

    def add_role(role)
      return if self.has_role?(role)
      self.roles << Role.find_by_ident(role)
    end



  validates_presence_of :login,:phone, :email
  #, :parent_id, :firm_id
  validates_format_of :phone,
                      :with => /^\+?\s?\d{6,13}/,
                      :message => "Должен быть цифровым!"
  
  validates_confirmation_of :password,  :on => :create
  validates_format_of   :email,
                        :with       => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                        :message    => 'Электронный ящик должен быть реальным'
 
  def prepare_password
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.password_salt, self.password_hash = salt, BCrypt::Password.create(password)
  end
  
  def password
    if self.password_hash.blank?
      @password
    else
      BCrypt::Password.new(self.password_hash) #unless self.password_hash.blank?
    end
  end



  def self.authenticate(login, password)
    user = User.find(:first, :conditions => ["login = ?", login])
    if user.blank?
      raise "Login or password blank"
    elsif BCrypt::Password.new(user.password_hash) == password
      user
    else
      raise "Имя пользователя или пароль не подходят "
    end
    user
  end

end

