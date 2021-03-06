require_relative "./service"
require "base64"
require "pry"

credential = Base64.decode64(ENV["SERVICE_ACCOUNT_JSON"])

service = SheetsService.new(credential: credential)
puts service.find(ARGV.first).spreadsheet_id
