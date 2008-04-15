class ChangeMonthGrand < ActiveRecord::Migration
  def self.up
    change_column :grands, :mounth, :string
  end

  def self.down
    remove_column :grand, :mounth
  end
end
