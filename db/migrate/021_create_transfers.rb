class CreateTransfers < ActiveRecord::Migration
  def self.up
    create_table :transfers do |t|
      t.column :name, :string
      t.column :summ, :float

    end
  end

  def self.down
    drop_table :transfers
  end
end
