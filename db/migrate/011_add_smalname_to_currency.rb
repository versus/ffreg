class AddSmalnameToCurrency < ActiveRecord::Migration
  def self.up
    add_column :currencies, :small, :string
  end

  def self.down
      remove_column :currencies, :small
  end
end
