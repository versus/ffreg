class AddParentIdToPayment < ActiveRecord::Migration
  def self.up

    add_column :payments, :parent_id, :integer, :null => false  #иерархия
  end

  def self.down
    remove_column :payments, :parent_id

  end
end
