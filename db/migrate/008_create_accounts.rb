class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.column :firm_id, :integer
      t.column :summ, :float
      t.column :currency_id, :integer
    end
  end

  def self.down
    drop_table :accounts
  end
end
