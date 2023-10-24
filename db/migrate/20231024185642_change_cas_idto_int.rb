class ChangeCasIdtoInt < ActiveRecord::Migration[7.1]
  def change
    change_column :applicants, :application_cas_id, 'bigint USING CAST(application_cas_id AS bigint)'
  end
end
