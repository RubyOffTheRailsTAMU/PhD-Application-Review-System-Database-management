require 'jwt'
require 'base64'

JWT_ALGORITHM = 'RS256'
JWT_PUBLIC_KEY = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('public_key.pem')))
#JWT_PUBLIC_KEY = OpenSSL::PKey::RSA.new(Base64.strict_decode64(ENV['PUBLIC_KEY']))
