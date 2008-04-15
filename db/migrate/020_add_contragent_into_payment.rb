class AddContragentIntoPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :contragent, :string 
  end

  def self.down
    remove_column :payments, :contragent, :string 

  end
end
