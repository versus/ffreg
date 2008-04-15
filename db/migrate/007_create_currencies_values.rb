class CreateCurrenciesValues < ActiveRecord::Migration
  def self.up
    create_table :currencies_values do |t|
        t.column :crossrate, :float
        t.column :create_at, :timestamp
        t.column :loss, :float
        t.column :ratio, :float
        t.column :currency_id, :integer
    end
  end

  def self.down
    drop_table :currencies_values
  end
end
