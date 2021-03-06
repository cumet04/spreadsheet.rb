require_relative "./service"
require "base64"
require "pry"

credential = Base64.decode64(ENV["SERVICE_ACCOUNT_JSON"])

service = GoogleSheets::Service.new(credential: credential)
service.find(ARGV.first).tap do |sheet|
  puts sheet.worksheet_names.to_s # ["シート1", "シート2"]
  sheet.write_range("A1", [[1, 2, 3], ["=B1"]], worksheet: "シート2")
  puts sheet.read_range("A1", worksheet: "シート2").to_s                       # [["1"]]
  puts sheet.read_range("A1:C2", worksheet: "シート2").to_s                    # [["1", "2", "3"], ["2"]]
  puts sheet.read_range("A1:C2", worksheet: "シート2", format: "FORMULA").to_s # [["1", "2", "3"], ["=B1"]]
end
