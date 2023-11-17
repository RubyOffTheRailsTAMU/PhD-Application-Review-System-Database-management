class ApplicantsController < ApplicationController

  def uploads_handler
    @x = 5
    @y = 3
    render 'uploads_handler'
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
    if unique_in_categorized_headers.size > 0
      if unique_in_fields.size > 0 # if there are unique headers AND unique fields
        # wait for user input
        print("user input needed\n")
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
    def savedata
      jsonData = getData
      jsonData.each do |data|
        next if Applicant.exists?(application_cas_id: data['cas_id'])

        saveOneDate(data)
      end

      file_path = session[:excel_file_path] # Get file path from session
      # At this point, it is assumed that the file was found successfully, or else Rails would have shown an error earlier.
      # Proceed to delete the file.
      File.delete(file_path)
      # render json: { message: "Application data saved successfully. Uploaded file has been deleted." }
      render 'upload_success'
    end

    def saveOneDate(data)
      # xlsx_controller = XlsxController.new
      # data=xlsx_controller.tojson[0]
      # uri = URI('http://localhost:3000/xlsx/tojson')
      # response = Net::HTTP.get(uri)

      # data = JSON.parse(response)[0]

      # json_data = render_to_string(controller: 'xlsx', action: 'tojson')[0]
      # data = JSON.parse(json_data)[0]\

      applicant = Applicant.create(
        application_cas_id: data['cas_id'],
        application_name: data['Combined name'],
        application_gender: data['gender'],
        application_citizenship_country: data['citizenship_country_name'],
        application_dob: data['1990-07-26'],
        application_email: data['email'],
        application_degree: data['Applied Degree'],
        application_submitted: data['designation_submitted_date_0'],
        application_status: data['application_status_0'],
        application_research: 'research_interests111111',
        application_faculty: 'faculty_name'
      )

      applicant.create_toefl(
        application_toefl_listening: data['toefl']['listening'],
        application_toefl_reading: data['toefl']['reading'],
        application_toefl_result: data['toefl']['result'],
        application_toefl_speaking: data['toefl']['speaking'],
        application_toefl_writing: data['toefl']['writing']
      )

      applicant.create_gre(
        application_gre_quantitative_scaled: data['gre']['quantitativeScaled'],
        application_gre_quantitative_percentile: data['gre']['quantitativePercentile'],
        application_gre_verbal_scaled: data['gre']['verbalScaled'],
        application_gre_verbal_percentile: data['gre']['verbalPercentile'],
        application_gre_analytical_scaled: data['gre']['analyticalScaled'],
        application_gre_analytical_percentile: data['gre']['analyticalPercentile']
      )

      applicant.create_application_ielt(
        application_ielts_listening: data['ielts']['listening'],
        application_ielts_reading: data['ielts']['reading'],
        application_ielts_result: data['ielts']['result'],
        application_ielts_speaking: data['ielts']['speaking'],
        application_ielts_writing: data['ielts']['writing']
      )

      data['school'].each do |school|
        applicant.schools.create(
          application_school_name: school['name'],
          application_school_level: school['level'],
          application_school_quality_points: school['qualityPoints'],
          application_school_gpa: school['GPA'],
          application_school_credit_hours: school['creditHours']
        )
      end
    end

    def getData
      excel_file_path = session[:excel_file_path] # Get file path from session
      excel = Roo::Excelx.new(excel_file_path) # New, uses file path from session
      # excel = Roo::Excelx.new(Rails.root.join('Dummy_data.xlsx')) # Old
      excel.default_sheet = excel.sheets.first

      field_headers = excel.row(1)

      # check if field table is empty
      if Field.all == []
        # Store field ids in a hash to avoid repeated database lookups
        field_ids = field_headers.map do |header|
          field = Field.find_or_create_by!(field_name: header)
          [header, field.id]
        end.to_h
      else
        # Store field ids in a hash to avoid repeated database lookups
        # if header is not unique, set many fields to True
        # field_ids = field_headers.map do |header|
        #   field = Field.find_or_create_by!(field_name: header)
        #   [header, field.id]
        # end.to_h
      end

      # handle subgroups

      data = []
      # Starting from the second row, as the first row contains headers
      (2..excel.last_row).each do |i|
        row = spreadsheet.row(i)

        # Create data entries for each field value
        field_headers.each_with_index do |header, index|
          Data.create!(
            group_id: group.id,
            field_id: field_ids[header],
            data_value: row[index + 1] # +1 because row includes the group name
          )
        end
      end

      2.upto(excel.last_row) do |line|
        data << Hash[header.zip(excel.row(line))]
      end

      schools = %w[0 1 2]

      data.each do |person|
        # Change the type of cas_id to string
        person['cas_id'] = person['cas_id'].to_i.to_s
        # ignore duplicate cas_id

        person['school'] = []

        schools.each do |school|
          next unless person['gpas_by_transcript_school_name_' + school] != nil

          schoolInfo = {}
          schoolInfo['name'] = person['gpas_by_transcript_school_name_' + school]
          schoolInfo['level'] = person['gpas_by_transcript_school_level_' + school]
          schoolInfo['qualityPoints'] = person['gpas_by_transcript_quality_points_' + school]
          schoolInfo['GPA'] = person['gpas_by_transcript_gpa_' + school]
          schoolInfo['creditHours'] = person['gpas_by_transcript_credit_hours_' + school]
          person['school'].push(schoolInfo)
        end

        person['gre'] = {}
        person['gre']['quantitativeScaled'] = person['gre_quantitative_scaled']
        person['gre']['quantitativePercentile'] = person['gre_quantitative_percentile']
        person['gre']['verbalScaled'] = person['gre_verbal_scaled']
        person['gre']['verbalPercentile'] = person['gre_verbal_percentile']
        person['gre']['analyticalScaled'] = person['gre_analytical_scaled']
        person['gre']['analyticalPercentile'] = person['gre_analytical_percentile']

        person['ielts'] = {}
        person['ielts']['reading'] = person['ielts_reading_score']
        person['ielts']['writing'] = person['ielts_writing_score']
        person['ielts']['listening'] = person['ielts_listening_score']
        person['ielts']['speaking'] = person['ielts_speaking_score']
        person['ielts']['overall'] = person['ielts_overall_band_score']

        person['toefl'] = {}
        person['toefl']['listening'] = person['toefl_ibt_listening']
        person['toefl']['reading'] = person['toefl_ibt_reading']
        person['toefl']['result'] = person['toefl_ibt_result']
        person['toefl']['speaking'] = person['toefl_ibt_speaking']
        person['toefl']['writing'] = person['toefl_ibt_writing']

        if person['Applied Degree'] == 'Computer Engineering'
          person['research_areas'] = {}
          person['research_areas']['firstChoice'] =
person['custom_questions_6110713646751957645_below_are_the_research_areas_please_choice_your_first_choice_or_none']
          person['research_areas']['secondChoice'] =
person['custom_questions_7865888513109191199_below_are_the_research_areas_please_choose_your_second_choice_or_none']
          person['research_areas']['thirdChoice'] =
person['custom_questions_8141472238696201795_below_are_the_research_areas_please_choose_your_third_choice_or_none']

          person['interested_faculties'] = []
          person.each do |key, value|
            if key.start_with?('custom_questions_8197256583460761100_please_identify_the_faculty_you_are_interested_in_doing_research_with_2_names_recommended_select_all_that_apply_') && !value.nil?
              if value == 'Other' && !person['custom_questions_6168456734222347809_if_you_chose_other_please_list_the_name_of_the_faculty_member'].nil?
                otherAdvisors = person['custom_questions_6168456734222347809_if_you_chose_other_please_list_the_name_of_the_faculty_member'].split(/\n /)
                otherAdvisors.each do |advisor|
                  person['interested_faculties'].push(advisor)
                end
              else
                person['interested_faculties'].push(value)
              end
            end
          end
        end

        next unless person['Applied Degree'] == 'Computer Science'

        person['research_areas'] = {}
        person['research_areas']['firstChoice'] =
person['custom_questions_6942390792507652217_below_are_the_research_areas_please_choice_your_first_choice_or_none']
        person['research_areas']['secondChoice'] =
person['custom_questions_8781135533764607742_below_are_the_research_areas_please_choose_your_second_choice_or_none']
        person['research_areas']['thirdChoice'] =
person['custom_questions_2141187173743149604_below_are_the_research_areas_please_choose_your_third_choice_or_none']

        person['interested_faculties'] = []
        person.each do |key, value|
          if key.start_with?('custom_questions_4381114538874729882_please_identify_the_faculty_you_are_interested_in_doing_research_with_2_names_recommended_select_all_that_apply_') && !value.nil?
            if value == 'Other' && !person['custom_questions_33951003881150694_if_you_chose_other_please_list_the_name_of_the_faculty_member'].nil?
              otherAdvisors = person['custom_questions_33951003881150694_if_you_chose_other_please_list_the_name_of_the_faculty_member'].split(/\n /)
              otherAdvisors.each do |advisor|
                person['interested_faculties'].push(advisor)
              end
            else
              person['interested_faculties'].push(value)
            end
          end
        end

        # person['CEQuestions']={}
        # person.each do |key,value|

        #   if key.start_with?("custom_questions_6110713646751957645_below_are_the_research_areas_please_choice_your_first_choice_or_none") ||
        #     key.start_with?("custom_questions_7865888513109191199_below_are_the_research_areas_please_choose_your_second_choice_or_none") ||
        #     key.start_with?("custom_questions_8141472238696201795_below_are_the_research_areas_please_choose_your_third_choice_or_none") ||
        #     key.start_with?("custom_questions_8197256583460761100_please_identify_the_faculty_you_are_interested_in_doing_research_with_2_names_recommended_select_all_that_apply_") ||
        #     key.start_with?("custom_questions_6168456734222347809_if_you_chose_other_please_list_the_name_of_the_faculty_member")
        #     person['CEQuestions'][key]=value
        #   end
        # end

        #   person['CSQuestions']={}
        #   person.each do |key,value|

        #     if key.start_with?("custom_questions_6942390792507652217_below_are_the_research_areas_please_choice_your_first_choice_or_none") ||
        #       key.start_with?("custom_questions_8781135533764607742_below_are_the_research_areas_please_choose_your_second_choice_or_none") ||
        #       key.start_with?("custom_questions_2141187173743149604_below_are_the_research_areas_please_choose_your_third_choice_or_none") ||
        #       key.start_with?("custom_questions_4381114538874729882_please_identify_the_faculty_you_are_interested_in_doing_research_with_2_names_recommended_select_all_that_apply_") ||
        #       key.start_with?("custom_questions_33951003881150694_if_you_chose_other_please_list_the_name_of_the_faculty_member")
        #       person['CSQuestions'][key]=value
        #     end
        # end
      # end

      data
    end
  end
end
