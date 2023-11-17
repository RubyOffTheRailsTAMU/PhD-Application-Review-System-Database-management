class ChangeNameService
  def self.rename
    connection = ActiveRecord::Base.connection
    connection.rename_column(:gres, :quantitative, :application_gre_quantitative_scaled)
  end
end
