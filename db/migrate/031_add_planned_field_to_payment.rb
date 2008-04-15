class AddPlannedFieldToPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :month, :string #плановый месяц 
    add_column :payments,  :year, :integer #плановый год 
    remove_column :payments, :recurring
    remove_column :payments, :term
  end

  def self.down
    remove_column :payments, :month
    remove_column :payments, :year

  end
end
