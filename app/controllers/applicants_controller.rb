class ApplicantsController < ApplicationController
  def savedata
    jsonData=getData()
    jsonData.each do |data|
      saveOneDate(data)
    end

    render json: { message: "Application data saved successfully" }
  end

  def saveOneDate(data)
        # xlsx_controller = XlsxController.new
    # data=xlsx_controller.tojson[0]
    # uri = URI('http://localhost:3000/xlsx/tojson')
    # response = Net::HTTP.get(uri)

    # data = JSON.parse(response)[0]


    # json_data = render_to_string(controller: 'xlsx', action: 'tojson')[0]
    # data = JSON.parse(json_data)[0]\

    applicant=Applicant.create(
      application_cas_id: data["cas_id"],
      application_name: data["Combined name"],
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
      application_toefl_listening: data["toefl"]["listening"],
      application_toefl_reading: data["toefl"]["reading"],
      application_toefl_result: data["toefl"]["result"],
      application_toefl_speaking: data["toefl"]["speaking"],
      application_toefl_writing: data["toefl"]["writing"]
    )

    applicant.create_gre(
      application_gre_quantitative_scaled: data["gre"]["quantitativeScaled"],
      application_gre_quantitative_percentile: data["gre"]["quantitativePercentile"],
      application_gre_verbal_scaled: data["gre"]["verbalScaled"],
      application_gre_verbal_percentile: data["gre"]["verbalPercentile"],
      application_gre_analytical_scaled: data["gre"]["analyticalScaled"],
      application_gre_analytical_percentile: data["gre"]["analyticalPercentile"]
    )

    applicant.create_application_ielt(
      application_ielts_listening: data["ielts"]["listening"],
      application_ielts_reading: data["ielts"]["reading"],
      application_ielts_result: data["ielts"]["result"],
      application_ielts_speaking: data["ielts"]["speaking"],
      application_ielts_writing: data["ielts"]["writing"]
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

  def getData()
    excel = Roo::Excelx.new(Rails.root.join('Dummy_data.xlsx'))
    excel.default_sheet = excel.sheets.first

    header = excel.row(1)
    data = []

    2.upto(excel.last_row) do |line|
      data << Hash[header.zip(excel.row(line))]
    end

    schools=['0','1','2']

    data.each do |person|
      # Change the type of cas_id to string
      person['cas_id']=person['cas_id'].to_i.to_s

      person['school']=[]

      schools.each do |school|
        if person['gpas_by_transcript_school_name_'+school]!=nil
          schoolInfo={}
          schoolInfo['name']=person['gpas_by_transcript_school_name_'+school]
          schoolInfo['level']=person['gpas_by_transcript_school_level_'+school]
          schoolInfo['qualityPoints']=person['gpas_by_transcript_quality_points_'+school]
          schoolInfo['GPA']=person['gpas_by_transcript_gpa_'+school]
          schoolInfo['creditHours']=person['gpas_by_transcript_credit_hours_'+school]
          person['school'].push(schoolInfo)
        end
      end

      person['gre']={}
      person['gre']['quantitativeScaled']=person['gre_quantitative_scaled']
      person['gre']['quantitativePercentile']=person['gre_quantitative_percentile']
      person['gre']['verbalScaled']=person['gre_verbal_scaled']
      person['gre']['verbalPercentile']=person['gre_verbal_percentile']
      person['gre']['analyticalScaled']=person['gre_analytical_scaled']
      person['gre']['analyticalPercentile']=person['gre_analytical_percentile']

      person['ielts']={}
      person['ielts']['reading']=person['ielts_reading_score']
      person['ielts']['writing']=person['ielts_writing_score']
      person['ielts']['listening']=person['ielts_listening_score']
      person['ielts']['speaking']=person['ielts_speaking_score']
      person['ielts']['overall']=person['ielts_overall_band_score']

      person['toefl']={}
      person['toefl']['listening']=person['toefl_ibt_listening']
      person['toefl']['reading']=person['toefl_ibt_reading']
      person['toefl']['result']=person['toefl_ibt_result']
      person['toefl']['speaking']=person['toefl_ibt_speaking']
      person['toefl']['writing']=person['toefl_ibt_writing']

      if person['Applied Degree']=='Computer Engineering'
        person['research_areas']={}
        person['research_areas']['firstChoice']=person['custom_questions_6110713646751957645_below_are_the_research_areas_please_choice_your_first_choice_or_none']
        person['research_areas']['secondChoice']=person['custom_questions_7865888513109191199_below_are_the_research_areas_please_choose_your_second_choice_or_none']
        person['research_areas']['thirdChoice']=person['custom_questions_8141472238696201795_below_are_the_research_areas_please_choose_your_third_choice_or_none']

        person['interested_faculties']=[]
        person.each do |key,value|

          if key.start_with?("custom_questions_8197256583460761100_please_identify_the_faculty_you_are_interested_in_doing_research_with_2_names_recommended_select_all_that_apply_") && value!=nil
            if value=='Other' && person['custom_questions_6168456734222347809_if_you_chose_other_please_list_the_name_of_the_faculty_member']!=nil
              otherAdvisors=person['custom_questions_6168456734222347809_if_you_chose_other_please_list_the_name_of_the_faculty_member'].split(/\n /)
              otherAdvisors.each do |advisor|
                person['interested_faculties'].push(advisor)
              end
            else
              person['interested_faculties'].push(value)
            end

          end
        end

      end

      if person['Applied Degree']=='Computer Science'
        person['research_areas']={}
        person['research_areas']['firstChoice']=person['custom_questions_6942390792507652217_below_are_the_research_areas_please_choice_your_first_choice_or_none']
        person['research_areas']['secondChoice']=person['custom_questions_8781135533764607742_below_are_the_research_areas_please_choose_your_second_choice_or_none']
        person['research_areas']['thirdChoice']=person['custom_questions_2141187173743149604_below_are_the_research_areas_please_choose_your_third_choice_or_none']

        person['interested_faculties']=[]
        person.each do |key,value|

          if key.start_with?("custom_questions_4381114538874729882_please_identify_the_faculty_you_are_interested_in_doing_research_with_2_names_recommended_select_all_that_apply_") && value!=nil
            if value=='Other' && person['custom_questions_33951003881150694_if_you_chose_other_please_list_the_name_of_the_faculty_member']!=nil
              otherAdvisors=person['custom_questions_33951003881150694_if_you_chose_other_please_list_the_name_of_the_faculty_member'].split(/\n /)
              otherAdvisors.each do |advisor|
                person['interested_faculties'].push(advisor)
              end
            else
              person['interested_faculties'].push(value)
            end

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

    end

    return data
  end
end
