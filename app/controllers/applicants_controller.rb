class ApplicantsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def uploads_handler
    old_fields, new_fields, user_input_needed, excel_file_path = process_input #Get old and new fields from process_input
    puts "excel_file_path righhht now: #{excel_file_path}"
    @old_fields = old_fields
    @new_fields = new_fields
    @excel_file_path = excel_file_path
    if user_input_needed
      render "applicants/uploads_handler"
    else
      rename_me_later(nil, nil)
    end
  end

  def uploads_handler_post
    # Access data from the client

    old_fields_json = params[:old_fields_json]
    new_fields_json = params[:new_fields_json]
    excel_file_path = params[:excel_file_path]

    puts "old_fields: #{old_fields_json}"
    puts "new_fields: #{new_fields_json}"
    puts "excel_file_path: #{excel_file_path}"
    rename_me_later(old_fields_json, new_fields_json)
    # Optionally, you can render a response or redirect to another page
    render json: { message: "Data received successfully" }
  end

  def process_input
    excel_file_path = session[:excel_file_path] # Get file path from session
    #check if excel or csv file
    if excel_file_path.end_with?(".xlsx") || excel_file_path.end_with?(".xls")
      spreadsheet = Roo::Excelx.new(excel_file_path) # New, uses file path from session
    elsif excel_file_path.end_with?(".csv")
      spreadsheet = Roo::CSV.new(excel_file_path) # New, uses file path from session
    end

    spreadsheet.default_sheet = spreadsheet.sheets.first

    field_headers = spreadsheet.row(1)

    # Process the headers
    headers = spreadsheet.row(1)
    categorized_headers = process_headers(headers)

    # get current headers from fields table
    fields = Field.where(field_used: true).pluck(:field_name)
    #note: cas_id, name, email and degree should always be in fields table

    # compute difference between current headers and new headers
    categorized_header_keys = Set.new(categorized_headers.keys)
    fields_set = Set.new(fields)
    common_elements = categorized_header_keys & fields_set
    unique_in_categorized_headers = categorized_header_keys - fields_set
    unique_in_fields = fields_set - categorized_header_keys
    # Output the results
    # puts "Common elements: #{common_elements.to_a}"
    # puts "Unique in categorized headers: #{unique_in_categorized_headers.to_a}"
    # puts "Unique in fields: #{unique_in_fields.to_a}"

    # comment one or the other for testing of logic below.
    # unique_in_fields = {}
    # unique_in_categorized_headers = {}
    # todo: consider non used fields for new ones too

    user_input_needed = false
    if unique_in_categorized_headers.size > 0
      if unique_in_fields.size > 0 # if there are unique headers AND unique fields
        user_input_needed = true
      else # only new headers, add to fields table
        unique_in_categorized_headers.each do |header|
          is_many = categorized_headers[header].is_a?(Hash)
          print("field name: #{header}, is_many: #{is_many}\n")
          Field.create!(field_name: header, field_alias: header, field_used: true, field_many: is_many)
        end
      end
    elsif unique_in_fields.size > 0 # no unique headers, only unique fields
      # turn off fields that are not in the new spreadsheet
      unique_in_fields.each do |field|
        print("field name: #{field}\n")
        Field.find_by(field_name: field).update(field_used: false)
      end
    end
    return unique_in_fields, unique_in_categorized_headers, user_input_needed, excel_file_path
  end

  def rename_me_later(old_fields_json, new_fields_json)
    excel_file_path = session[:excel_file_path] # Get file path from session
    puts "excel_file_path RENAME ME SEXY: #{excel_file_path}"
    puts "hey i just met you, and this is crazy, but here's my number, so remane me later"

    if old_fields_json.nil? || new_fields_json.nil?
      puts "old_fields_json or new_fields_json is nil"
    end

    # todo: update fields table with new field values from jsons

    #spreadsheet = Roo::Excelx.new(session[:excel_file_path]) # New, uses file path from session

    #check if excel or csv file
    if excel_file_path.end_with?(".xlsx") || excel_file_path.end_with?(".xls")
      spreadsheet = Roo::Excelx.new(excel_file_path) # New, uses file path from session
    elsif excel_file_path.end_with?(".csv")
      spreadsheet = Roo::CSV.new(excel_file_path) # New, uses file path from session
    end

    spreadsheet.default_sheet = spreadsheet.sheets.first

    field_headers = spreadsheet.row(1)

    # Process the headers
    headers = spreadsheet.row(1)
    categorized_headers = process_headers(headers)

    # Now process each row
    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      categorized_headers.each do |key, header_value|
        field_value = if header_value.is_a?(Hash)
            # For 'many' headers, collapse the dictionary to just the values as comma-separated
            values_array = header_value.keys.map { |sub_key| row[headers.index(header_value[sub_key])] }
            values_array.join(", ")
          else
            # For regular headers, fetch the value directly from the row
            row[headers.index(header_value)] || ""
          end

        field = Field.find_by(field_name: key)
        puts "key: #{key}"
        puts "field value: #{field_value}"
        field.infos.create(data_value: field_value, cas_id: row[header.index("cas_id")], subgroup: key)
      end
    end
    render "upload_success"
  end

  def process_headers(headers)
    categories = {}

    headers.each do |header|
      parts = header.split("_")
      if parts.size > 1 && parts.last.match?(/^\d+$/)
        # It's a header of the form "word1_word2_wordN_digit"
        key = parts[0...-1].join("_") # All parts except the last one
        sub_key = parts.last
        (categories[key] ||= {})[sub_key] = header
      else
        categories[header] = header
      end
    end

    categories
  end

  def savedata
    jsonData = getData
    jsonData.each do |data|
      next if Applicant.exists?(application_cas_id: data["cas_id"])

      saveOneDate(data)
    end

    file_path = session[:excel_file_path] # Get file path from session
    # At this point, it is assumed that the file was found successfully, or else Rails would have shown an error earlier.
    # Proceed to delete the file.
    File.delete(file_path)
    # render json: { message: "Application data saved successfully. Uploaded file has been deleted." }
    render "upload_success"
  end
end