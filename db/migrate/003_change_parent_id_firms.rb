class ChangeParentIdFirms < ActiveRecord::Migration
  def self.up
    change_column :firms, :parent_id, :integer, :default => 0
  end

  def self.down
  end
end
