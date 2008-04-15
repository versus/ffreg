class CreateFirms < ActiveRecord::Migration
  def self.up
    create_table :firms do |t|
      t.column :name, :string
      t.column :phone, :string
    end
  end

  def self.down
    drop_table :firms
  end
end
