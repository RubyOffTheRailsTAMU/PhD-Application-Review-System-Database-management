class ApplicantsController < ApplicationController

protect_from_forgery with: :null_session

  def uploads_handler
    @x = 5
    @y = 3
    old_fields, new_fields = process_input #Get old and new fields from process_input

    @old_fields = old_fields
    @new_fields = new_fields
    render 'applicants/uploads_handler'
  end

  def process_input
    excel_file_path = session[:excel_file_path] # Get file path from session
    spreadsheet = Roo::Excelx.new(excel_file_path) # New, uses file path from session
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
    return unique_in_fields, unique_in_categorized_headers
  end

  def rename_me_later
    # todo: consider non used fields for new ones too 
    if unique_in_categorized_headers.size > 0
      if unique_in_fields.size > 0 # if there are unique headers AND unique fields
        #render 'applicants/uploads_handler'
        render 'applicants/uploads_handler', locals: {old_fields: @old_fields, new_fields: @new_fields }
        print("user input needed\n")
        exit
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
        field.infos.create(data_value: field_value, cas_id: row[headers.index("cas_id")].to_i.to_s, subgroup: key)
      end
    end
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
