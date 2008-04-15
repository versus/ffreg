class CreateBudgets < ActiveRecord::Migration
  def self.up
    create_table :budgets do |t|
      t.column :month, :string
      t.column :year, :integer
      t.column :status, :string, :default => 0
    end
  end

  def self.down
    drop_table :budgets
  end
end
