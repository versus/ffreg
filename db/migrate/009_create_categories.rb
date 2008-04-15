class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column :parent_id, :integer    # нужен для организации дерева из категорий
      t.column :name, :string          # имя категории
      t.column :sort, :integer         # поле для сортировки
      t.column :typo, :string         # показатель типа категории:
    end
  end

  def self.down
    drop_table :categories
  end
end
