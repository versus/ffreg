class Dropsometables < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :workdays
    drop_table :sentries
  end
end
