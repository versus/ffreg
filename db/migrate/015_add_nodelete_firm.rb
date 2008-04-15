class AddNodeleteFirm < ActiveRecord::Migration
  def self.up
    add_column :firms, :nodelete, :boolean, :default => false
  end

  def self.down
  end
end
