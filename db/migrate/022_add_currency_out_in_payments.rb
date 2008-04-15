class AddCurrencyOutInPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :currency_out, :integer, :default => 0
  end

  def self.down
  end
end
