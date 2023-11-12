class ReferToSubgroup < ActiveRecord::Migration[7.1]
  def change
    add_reference :datas, :subgroup, foreign_key: { to_table: :subgroups, on_delete: :cascade }
  end
end
