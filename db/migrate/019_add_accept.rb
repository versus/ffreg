class AddAccept < ActiveRecord::Migration
  def self.up
add_column :accepts, :payment_id, :integer
add_column :accepts, :create_at, :timestamp
add_column :accepts, :user_id, :integer
add_column :accepts, :comment, :text

  end

  def self.down
  end
end
