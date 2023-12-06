class SetFieldsNotNull < ActiveRecord::Migration[7.1]
  def change
    change_column :fields, :field_name, :string, null: false
    change_column :fields, :field_alias, :string, null: false
    change_column :fields, :field_used,  :boolean, null: false
    change_column :fields, :field_many,  :boolean, null: false
  end
end
