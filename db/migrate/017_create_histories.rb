class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.column :create_at, :timestamp
      t.column :user, :string
      t.column :logstring, :string
    end
  end

  def self.down
    drop_table :histories
  end
end
