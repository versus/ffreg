class AddPaymentPlan < ActiveRecord::Migration
  def self.up
     add_column :payments, :planned, :boolean  #плановая заявка? 
     add_column :payments, :recurring, :boolean #периодическая ?
     add_column :payments, :create_planned, :timestamp # дата создания заявки
     add_column :payments, :term, :integer # срок действия заявки если периодическая
  end

  def self.down
     remove_column :payments, :planned
     remove_column :payments, :recurring
     remove_column :payments, :create_planned
     remove_column :payments, :term
  end
end
