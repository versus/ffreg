class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :login, :string              # имя пользователя
      t.column :password_salt , :string     # пароль
      t.column :password_hash , :string
      t.column :parent_id, :integer, :null => false         # должностная иерархия
      t.column :fio, :string                # ФИО
      t.column :firm_id, :integer           # фирма в которой работает
      t.column :create_at, :timestamp       # время создания записи в базе
      t.column :position, :string           # должность
      t.column :phone, :string              # телефон пользователя
      t.column :email, :string              # электронный адрес
      t.column :status, :integer            # 

    end
  end

  def self.down
    drop_table :users
  end
end
