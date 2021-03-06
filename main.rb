require_relative "./service"
require "base64"
require "pry"

credential = Base64.decode64(ENV["SERVICE_ACCOUNT_JSON"])

service = GoogleSheets::Service.new(credential: credential)
service.find(ARGV.first).write_range("A1", [[1, 2, 3]])
