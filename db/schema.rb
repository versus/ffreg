# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 32) do

  create_table "accepts", :force => true do |t|
    t.column "payment_id", :integer
    t.column "create_at",  :datetime
    t.column "user_id",    :integer
    t.column "comment",    :text
  end

  create_table "accounts", :force => true do |t|
    t.column "firm_id",     :integer
    t.column "summ",        :float
    t.column "currency_id", :integer
    t.column "name",        :string
  end

  create_table "budgets", :force => true do |t|
    t.column "month",   :string
    t.column "year",    :integer
    t.column "status",  :string,  :default => "0"
    t.column "firm_id", :integer
  end

  create_table "bugzillas", :force => true do |t|
    t.column "create_at", :datetime
    t.column "user",      :string
    t.column "problem",   :text
    t.column "prio",      :integer
  end

  create_table "categories", :force => true do |t|
    t.column "parent_id", :integer
    t.column "name",      :string
    t.column "sort",      :integer
    t.column "typo",      :string
  end

  create_table "currencies", :force => true do |t|
    t.column "name",  :string
    t.column "abbr",  :string
    t.column "small", :string
  end

  create_table "currencies_values", :force => true do |t|
    t.column "crossrate",   :float
    t.column "create_at",   :datetime
    t.column "loss",        :float
    t.column "ratio",       :float
    t.column "currency_id", :integer
  end

  create_table "events", :force => true do |t|
    t.column "create_at",  :datetime
    t.column "subject",    :string
    t.column "status",     :integer
    t.column "user_from",  :integer
    t.column "user_to",    :integer
    t.column "body",       :text
    t.column "payment_id", :integer
  end

  create_table "firms", :force => true do |t|
    t.column "name",      :string
    t.column "phone",     :string
    t.column "parent_id", :integer, :default => 0,     :null => false
    t.column "nodelete",  :boolean, :default => false
    t.column "hidden",    :boolean, :default => false
  end

  create_table "grands", :force => true do |t|
    t.column "create_at",   :datetime
    t.column "user_id",     :integer
    t.column "firm_id",     :integer
    t.column "category_id", :integer
    t.column "plan",        :float
    t.column "fact",        :float
    t.column "year",        :integer
    t.column "mounth",      :string
    t.column "currency_id", :integer
    t.column "accept",      :boolean
  end

  create_table "histories", :force => true do |t|
    t.column "create_at", :datetime
    t.column "user",      :string
    t.column "logstring", :string
  end

  create_table "news", :force => true do |t|
    t.column "title",     :string
    t.column "create_at", :datetime
    t.column "message",   :text
    t.column "user_id",   :integer
  end

  create_table "payments", :force => true do |t|
    t.column "title",          :string
    t.column "create_at",      :datetime
    t.column "close_at",       :datetime
    t.column "summ",           :float
    t.column "category_id",    :integer
    t.column "comment",        :text
    t.column "user_id",        :integer
    t.column "currency_id",    :integer
    t.column "firm_id",        :integer
    t.column "status",         :string
    t.column "prio",           :integer
    t.column "contragent",     :string
    t.column "currency_out",   :integer,  :default => 0
    t.column "planned",        :boolean
    t.column "create_planned", :datetime
    t.column "month",          :string
    t.column "year",           :integer
    t.column "parent_id",      :integer,                 :null => false
  end

  create_table "roles", :force => true do |t|
    t.column "ident", :string, :limit => 100, :default => "", :null => false
  end

  add_index "roles", ["ident"], :name => "index_roles_on_ident"

  create_table "roles_users", :id => false, :force => true do |t|
    t.column "role_id", :integer, :null => false
    t.column "user_id", :integer, :null => false
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id", :unique => true

  create_table "static_permissions", :force => true do |t|
    t.column "ident", :string, :limit => 100, :default => "", :null => false
  end

  add_index "static_permissions", ["ident"], :name => "index_static_permissions_on_ident"

  create_table "transfers", :force => true do |t|
    t.column "name", :string
    t.column "summ", :float
  end

  create_table "users", :force => true do |t|
    t.column "login",         :string
    t.column "password_salt", :string
    t.column "password_hash", :string
    t.column "parent_id",     :integer,  :null => false
    t.column "fio",           :string
    t.column "firm_id",       :integer
    t.column "create_at",     :datetime
    t.column "position",      :string
    t.column "phone",         :string
    t.column "email",         :string
    t.column "status",        :integer
  end

end
