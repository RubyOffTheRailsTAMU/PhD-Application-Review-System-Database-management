module Api
    module V1
      class SearchesController < ApplicationController
        # You might want to skip CSRF token for API requests
        # todo: use verification? 
        skip_before_action :verify_authenticity_token
        
        COLUMN_MAP = {
          'cas_id' => 'application_cas_id',
          'name' => 'application_name',
          'gender' => 'application_gender',
          'citizenship_country' => 'application_citizenship_country',
          'date_of_birth' => 'application_dob',
          'email' => 'application_email',
          'degree' => 'application_degree',
          'submitted' => 'application_submitted',
          'status' => 'application_status',
          'research' => 'application_research',
          'faculty' => 'application_faculty',
          'toefl_listening' => 'toefls.application_toefl_listening',
          'toefl_reading' => 'toefls.application_toefl_reading',
          'toefl_result' => 'toefls.application_toefl_result',
          'toefl_speaking' => 'toefls.application_toefl_speaking',
          'toefl_writing' => 'toefls.application_toefl_writing',
          'gre_quant_scaled' => 'gres.application_gre_quantitative_scaled',
          'gre_quant_percentile' => 'gres.application_gre_quantitative_percentile',
          'gre_verbal_scaled' => 'gres.application_gre_verbal_scaled',
          'gre_verbal_percentile' => 'gres.application_gre_verbal_percentile',
          'gre_analytical_scaled' => 'gres.application_gre_analytical_scaled',
          'gre_analytical_percentile' => 'gres.application_gre_analytical_percentile',
          'ielts_listening' => 'application_ielts.application_ielts_listening',
          'ielts_reading' => 'application_ielts.application_ielts_reading',
          'ielts_result' => 'application_ielts.application_ielts_result',
          'ielts_speaking' => 'application_ielts.application_ielts_speaking',
          'ielts_writing' => 'application_ielts.application_ielts_writing',
          'school_name' => 'schools.application_school_name',
          'school_level' => 'schools.application_school_level',
          'school_quality_points' => 'schools.application_school_quality_points',
          'school_gpa' => 'schools.application_school_gpa',
          'school_credit_hours' => 'schools.application_school_credit_hours'
        }
        def build_query(search_str)
          conditions = []
          values = []

          valid_columns = Applicant.column_names

           # Iterate over each direct association
          Applicant.reflect_on_all_associations.each do |association|
            # Get the associated class (e.g., Profile, or any other related model)
            associated_class = association.klass

            # Get the column names for the associated class and add them to our list
            valid_columns += associated_class.column_names.map { |column_name| "#{associated_class.table_name}.#{column_name}" }
          end

          puts valid_columns

          search_str.split.each do |constraint|
            key, operator, value = constraint.match(/([\w\.]+)([<>=~]+)(.+)/
          ).captures
        

            # replace short hand with column name
            key = COLUMN_MAP[key.downcase] || key

            #verify key is of column names
            unless valid_columns.include?(key.downcase)
              raise ActiveRecord::StatementInvalid.new("Invalid column name: #{key}")
            end
            
            case operator
            when "="
              conditions << "lower(#{key}) = ?"
              values << value.downcase
            when ">"
              conditions << "#{key} > ?"
              values << value.to_f
            when "<"
              conditions << "#{key} < ?"
              values << value.to_f
            when "~"
              conditions << "lower(#{key}) LIKE ?"
              values << "%#{value.downcase}%"
            end
          end
          [conditions.join(" AND "), *values]
        end

        def index
          begin
            query = params[:query]
            field = params[:field] 
            if query[0]=="*"
              search_str = query[1..-1]  # Get the query string from the request
              puts "Search string: #{search_str}"
      
              query, *values = build_query(search_str)
              #todo: optimize so joins are only when needed. 
              @results = Applicant.joins(:schools, :toefl, :gre, :application_ielt)
              .select('applicants.*, schools.*, toefls.*, gres.*, application_ielts.*')
              .distinct
              .where(query, *values)
                          
              puts @results.inspect
            else 
              #todo: validate fields even tho already done on input. 
              #todo: consider numerical feilds. 
              #@results = Applicant.where("lower(#{field} LIKE ? %#{query.downcase}%)")
              case field
              when "application_name"
                @results = Applicant.where("lower(application_name) LIKE ?", "%#{query.downcase}%")
              when "application_cas_id"
                @results = Applicant.where("application_cas_id LIKE ?", "%#{query}%")
              when "application_citizenship_country"
                  @results = Applicant.where("lower(application_citizenship_country) LIKE ?", "%#{query.downcase}%")
              when "application_degree"
                  @results = Applicant.where("lower(application_degree) LIKE ?", "%#{query.downcase}%")
              else
                @results = Applicant.where("lower(application_name) LIKE ?", "%#{query.downcase}%")
              end
            end

            puts @results
            render json: @results
          rescue ActiveRecord::StatementInvalid => e
            # Check for our custom error message, render a relevant JSON response
            if e.message.start_with?("Invalid column name:")
              render json: { error: e.message }, status: 400
            else
              # Handle other StatementInvalid errors here if necessary
            end
          end
        end
      end
    end
  end
  