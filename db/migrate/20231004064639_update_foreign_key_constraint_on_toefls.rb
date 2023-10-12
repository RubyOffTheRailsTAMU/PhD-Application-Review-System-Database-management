class UpdateForeignKeyConstraintOnToefls < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :toefls, :applicants
    add_foreign_key :toefls, :applicants, on_delete: :cascade
  end
end
