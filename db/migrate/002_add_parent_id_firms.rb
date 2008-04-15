class AddParentIdFirms < ActiveRecord::Migration
  def self.up
    add_column :firms, :parent_id, :integer
  end

  def self.down
  end
end
