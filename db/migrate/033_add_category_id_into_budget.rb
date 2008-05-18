class AddCategoryIdIntoBudget < ActiveRecord::Migration
  def self.up
     add_column :budgets, :category_id, :integer
  end

  def self.down
#    remove_column :budgets, :category_id
  end
end
