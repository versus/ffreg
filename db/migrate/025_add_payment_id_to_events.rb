class AddPaymentIdToEvents < ActiveRecord::Migration
  def self.up
      add_column :events, :payment_id, :integer
  end

  def self.down
     remove_column :events, :payment_id

  end

end
