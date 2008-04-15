class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.column :name, :string
      t.column :abbr, :string
    end
  end

  def self.down
    drop_table :currencies
  end
end
