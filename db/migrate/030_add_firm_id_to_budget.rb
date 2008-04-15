class AddFirmIdToBudget < ActiveRecord::Migration
  def self.up

    add_column :budgets, :firm_id, :integer

  end

  def self.down
    
  end
end
