class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :create_at, :timestamp
      t.column :subject,   :string
      t.column :status,    :integer
      t.column :user_from,   :integer
      t.column :user_to,  :integer
      t.column :body, :text
    end
  end

  def self.down
    drop_table :events
  end
end
