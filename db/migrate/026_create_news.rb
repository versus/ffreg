class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
        t.column :title, :string
        t.column :create_at, :timestamp
        t.column :message, :text
        t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :news
  end
end
