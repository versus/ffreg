class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :ident,  :string,  :limit => 100, :null => false
    end
    add_index :roles, :ident
    create_table(:roles_users, :id => false) do |t|
        t.column :role_id,            :integer, :null => false
        t.column :user_id,            :integer, :null => false
      end
      add_index :roles_users, [ :role_id, :user_id ], :unique => true
      
    create_table :static_permissions do |t|
      t.column :ident,         :string,    :limit => 100, :null => false
      end
     add_index :static_permissions, :ident
  end

  def self.down
    drop_table :roles
    drop_table :roles_users
    drop_table :static_permissions
  end
end
