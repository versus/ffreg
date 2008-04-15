class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.column :title, :string              #заголовок платежки
      t.column :create_at, :timestamp       #время создания платежки 
      t.column :close_at, :timestamp        #время закрытия платежки (дата проведения в грандтотал таблице)
      t.column :summ, :float                #общая сумма платежа
      t.column :category_id, :integer       #глобальная категория 
      t.column :comment, :text              #описание платежки
      t.column :user_id, :integer           #автор платежки
      t.column :currency_id, :integer       #валюта платежа
      t.column :firm_id, :integer           #фирма инициатора платежа
      t.column :status, :string             #статус платежа
      t.column :prio, :integer              #приоритетность платежа
    end
  end

  def self.down
    drop_table :payments
  end
end
