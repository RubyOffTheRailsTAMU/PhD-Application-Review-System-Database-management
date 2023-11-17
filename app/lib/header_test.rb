require 'roo'
require 'set'
# Define a method to process headers and categorize them
def process_headers(headers)
  categories = {}

  headers.each do |header|
    parts = header.split('_')
    if parts.size > 1 && parts.last.match?(/^\d+$/)
      # It's a header of the form "word1_word2_wordN_digit"
      key = parts[0...-1].join('_') # All parts except the last one
      sub_key = parts.last
      (categories[key] ||= {})[sub_key] = header
    else
      categories[header] = header
    end
  end

  categories
end

# Path to your Excel file
filename = 'lib/assets/Dummier_data-3.xlsx'
spreadsheet = Roo::Spreadsheet.open(filename)

# Process the headers
headers = spreadsheet.row(1)
categorized_headers = process_headers(headers)

# get current headers from fields table
fields = Field.where(field_used: true).pluck(:field_name)

# compute difference between current headers and new headers
categorized_header_keys = Set.new(categorized_headers.keys)
fields_set = Set.new(fields)
common_elements = categorized_header_keys & fields_set
unique_in_categorized_headers = categorized_header_keys - fields_set
unique_in_fields = fields_set - categorized_header_keys
# Output the results
puts "Common elements: #{common_elements.to_a}"
puts "Unique in categorized headers: #{unique_in_categorized_headers.to_a}"
puts "Unique in fields: #{unique_in_fields.to_a}"

#comment one or the other for testing of logic below. 
# unique_in_fields = {}
# unique_in_categorized_headers = {}

if unique_in_categorized_headers.size > 0 
  if unique_in_fields.size > 0 # if there are unique headers AND unique fields
    # wait for user input
    print("user input needed\n")
  else # only new headers, add to fields table
    unique_in_categorized_headers.each do |header| 
      is_many = categorized_headers[header].is_a?(Hash)
      #todo: determine if field is many or not
      print("field name: #{header}, is_many: #{is_many}\n")
      #Field.create!(field_name: header, field_alias: header, field_used: true, field_many: false)
    end
  end
elsif unique_in_fields.size > 0 # no unique headers, only unique fields
  #turn off fields that are not in the new spreadsheet
  unique_in_fields.each do |field|
    print("field name: #{field}\n")
    #Field.find_by(field_name: field).update(field_used: false)
  end
end



# Now process each row
data_rows = []

(2..spreadsheet.last_row).each do |i|
  row = spreadsheet.row(i)
  row_data = {}

  categorized_headers.each do |key, value|
    if value.is_a?(Hash)
      # The header was of the form "word1_word2_wordN_digit"
      # ie header is a many
      row_data[key] = value.transform_values { |header| row[headers.index(header)] }

    else
      # It's a single header, not of the form "word1_word2_wordN_digit"
      # ie header is not a many
      row_data[value] = row[headers.index(key)]
    end
    #todo: add to database
  end

  data_rows << row_data
end

# puts data_rows

