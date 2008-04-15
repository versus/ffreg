class CreateBugzillas < ActiveRecord::Migration
  def self.up
    create_table :bugzillas do |t|
      t.column :create_at, :timestamp
      t.column :user, :string
      t.column :problem, :text
      t.column :prio, :integer
    end
  end

  def self.down
    drop_table :bugzillas
  end
end
