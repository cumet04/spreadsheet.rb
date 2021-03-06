require_relative "./service"
require "base64"
require "pry"

credential = Base64.decode64(ENV["SERVICE_ACCOUNT_JSON"])

service = GoogleSheets::Service.new(credential: credential)
service.find(ARGV.first).tap do |sheet|
  puts sheet.worksheet_names
  sheet.write_range("A1", [[1, 2, 3]], worksheet: "シート2")
end
