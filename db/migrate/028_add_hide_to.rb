class AddHideTo < ActiveRecord::Migration
  def self.up
         add_column :firms, :hidden, :boolean, :default => false  #возможность скрывать фирмы из работы  
  end

  def self.down
        remove_column :firms, :hidden

  end
end
