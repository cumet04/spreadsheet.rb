require "stringio"
require "google/apis/sheets_v4"
require "google/apis/drive_v3"

class SheetsService
  def initialize(credential:)
    @credential = credential
  end

  def get_spreadsheet(id)
    sheets_service.get_spreadsheet(id)
  end

  private

  def sheets_service
    @sheets_service ||= Google::Apis::SheetsV4::SheetsService.new.tap do |s|
      s.authorization = authorizer
    end
  end

  def drive_service
    @drive_service ||= Google::Apis::DriveV3::DriveService.new.tap do |s|
      s.authorization = authorizer
    end
  end

  def authorizer
    @authorizer ||= Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(@credential),
      scope: %w(
        https://www.googleapis.com/auth/drive
        https://www.googleapis.com/auth/drive.file
        https://www.googleapis.com/auth/spreadsheets
      ),
    ).tap(&:fetch_access_token!)
  end
end

require "base64"

credential = Base64.decode64(ENV["SERVICE_ACCOUNT_JSON"])

service = SheetsService.new(credential: credential)
puts service.get_spreadsheet(ARGV.first).spreadsheet_id
