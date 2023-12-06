class UpdateForeignKeyConstraintOnGres < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :gres, :applicants
    add_foreign_key :gres, :applicants, on_delete: :cascade
  end
end
