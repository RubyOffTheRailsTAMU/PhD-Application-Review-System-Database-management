class User < ApplicationRecord
  self.table_name = 'users'
  has_secure_password
end
