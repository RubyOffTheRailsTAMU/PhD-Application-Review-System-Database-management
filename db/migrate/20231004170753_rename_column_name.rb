class RenameColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :toefls, :listening, :application_toefl_listening
    rename_column :toefls, :reading, :application_toefl_reading
    rename_column :toefls, :result, :application_toefl_result
    rename_column :toefls, :speaking, :application_toefl_speaking
    rename_column :toefls, :writing, :application_toefl_writing
    rename_column :gres, :quantitative_scaled, :application_gre_quantitative_scaled
    rename_column :gres, :quantitative_percentile, :application_gre_quantitative_percentile
    rename_column :gres, :verbal_scaled, :application_gre_verbal_scaled
    rename_column :gres, :verbal_percentile, :application_gre_verbal_percentile
    rename_column :gres, :analytical_scaled, :application_gre_analytical_scaled
    rename_column :gres, :analytical_percentile, :application_gre_analytical_percentile
    change_column_null :toefls, :application_toefl_listening, true
    change_column_null :toefls, :application_toefl_reading, true
    change_column_null :toefls, :application_toefl_result, true
    change_column_null :toefls, :application_toefl_speaking, true
    change_column_null :toefls, :application_toefl_writing, true
    change_column_null :gres, :application_gre_quantitative_scaled, true
    change_column_null :gres, :application_gre_quantitative_percentile, true
    change_column_null :gres, :application_gre_verbal_scaled, true
    change_column_null :gres, :application_gre_verbal_percentile, true
    change_column_null :gres, :application_gre_analytical_scaled, true
    change_column_null :gres, :application_gre_analytical_percentile, true
  end
end
