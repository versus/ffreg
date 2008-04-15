class CreateGrands < ActiveRecord::Migration
  def self.up
    create_table :grands do |t|
      t.column :create_at, :timestamp
      t.column :user_id, :integer
      t.column :firm_id, :integer
      t.column :category_id, :integer
      t.column :plan, :float
      t.column :fact, :float
      t.column :year, :integer
      t.column :mounth, :integer
      t.column :currency_id, :integer
      t.column :accept, :boolean
    end
  end

  def self.down
    drop_table :grands
  end
end
