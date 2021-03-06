require "stringio"
require "google/apis/sheets_v4"
require "google/apis/drive_v3"

module GoogleSheets
  class Sheet
    attr_reader :service, :spreadsheet

    def initialize(service, spreadsheet)
      @service = service
      @spreadsheet = spreadsheet
    end

    def write_range(range, values, as_row: false)
      service.update_spreadsheet_value(
        spreadsheet_id: spreadsheet.spreadsheet_id,
        range: range,
        values: values,
        as_row: as_row,
      )
    end
  end

  class Service
    def initialize(credential:)
      @credential = credential
    end

    def find(id)
      # DriveV3::DriveService#get_file with id=nil or id='' returns a empty(?) File object without any error.
      # So raise error explicitly if id is blank.
      raise "id is empty" unless id&.length > 0

      file = drive_service.get_file(id)
      # FIXME: want to raise a error when file is trashed, but DriveV3::File#trashed? don't work.

      Sheet.new(self, sheets_service.get_spreadsheet(id))
    end

    def find_by_name(folder_id:, name:)
      files = drive_service.list_files(
        q: [
          "'#{folder_id}' in parents",
          "name = '#{name}'",
        ].join(" and "),
      ).files

      raise "file not found" if files.count.zero?
      raise "multiple files found for single name" if files.count > 1

      find(files.first.id)
    end

    # range: ex) "A1:D1" or "A1"
    # values: array of array of value(number, string, ...)
    def update_spreadsheet_value(spreadsheet_id:, range:, values:, as_row: false)
      sheets_service.update_spreadsheet_value(
        spreadsheet_id,
        range,
        Google::Apis::SheetsV4::ValueRange.new(values: values),
        value_input_option: as_row ? "RAW" : "USER_ENTERED",
      )
    rescue Google::Apis::ClientError => e
      raise ApiError.new(e)
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

  class ApiError < StandardError
    attr_reader :original

    def initialize(original)
      @original = original
      body = original.body
      msg = JSON.parse(body)["error"] rescue body
      super(msg)
    end
  end
end
