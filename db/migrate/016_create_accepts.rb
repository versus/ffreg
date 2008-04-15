class CreateAccepts < ActiveRecord::Migration
  def self.up
    create_table :accepts do |t|
    end
  end

  def self.down
    drop_table :accepts
  end
end
