module Api
  module V1
    class SearchesController < ApplicationController
      # You might want to skip CSRF token for API requests
      # skip_before_action :verify_authenticity_token
      before_action :authenticate_request

      def field_names
        fields = Field.all
        render json: fields
      end

      def index
        puts "enter index"
        #back end validation
        field = params[:field]
        unless Field.where(field_used: true, field_alias: field).exists?
          render json: { error: "Invalid search field" }, status: :bad_request
          return
        end

        # Step 2: Retrieve the query parameter
        query = params[:query]
        # Check if it's an advanced search
        if query.start_with?("*")
          puts "advanced search"
          query_string = query[1..-1] # Remove the '*'
          parsed_queries = parse_query_string(query_string)

          # Step 2: Dynamically build the query
          matched_cas_ids_sets = []
          parsed_queries.each do |field, op, value|
            puts "field: #{field}, op: #{op}, value: #{value}"
            field_record = Field.find_by(field_used: true, field_alias: field)
            if field_record
              case op
              when "~"
                matched_cas_ids_sets << Info.joins(:field)
                  .where("fields.id = ? AND CAST(infos.data_value AS TEXT) ILIKE ?", field_record.id, "%#{value}%")
                  .pluck(:cas_id).uniq
              when "="
                matched_cas_ids_sets << Info.joins(:field)
                  .where("fields.id = ? AND infos.data_value = ?", field_record.id, value)
                  .pluck(:cas_id).uniq
              when "<", ">"
                if numeric?(value)
                  matched_cas_ids_sets << Info.joins(:field)
                    .where("fields.id = ? AND infos.data_value #{op} ?", field_record.id, value.to_f)
                    .pluck(:cas_id).uniq
                else
                  render json: { error: "Non-numeric value for numeric operation on field: #{field}" }, status: :bad_request
                  return
                end
              end
            else
              render json: { error: "Invalid search field: #{field}" }, status: :bad_request
              return
            end
          end

          # Intersecting the sets of matched cas_ids from each condition
          if matched_cas_ids_sets.present?
            matched_cas_ids = matched_cas_ids_sets.reduce(:&)
            puts "Matched CAS IDs: #{matched_cas_ids.inspect}"
          else
            render json: { error: "No valid conditions found in query" }, status: :bad_request
          end
        else
          # basic arse botch
          matched_cas_ids = Info.where("#{field} LIKE ?", "%#{query}%").pluck(:cas_id).uniq
        end
        @results = matched_cas_ids.map do |cas_id|
          infos = Info.joins(:field)
                      .where(cas_id: cas_id)
                      .select("infos.data_value", "fields.field_alias")

          # Aggregate data for each cas_id
          aggregated_data = infos.each_with_object({}) do |info, hash|
            if info.field_alias == "cas_id"
              hash[info.field_alias] = info.data_value.to_i
            else
              hash[info.field_alias] = info.data_value
            end
          end

          case operator
          when '='
            conditions << "lower(#{key}) = ?"
            values << value.downcase
          when '>'
            conditions << "#{key} > ?"
            values << value.to_f
          when '<'
            conditions << "#{key} < ?"
            values << value.to_f
          when '~'
            conditions << "lower(#{key}) LIKE ?"
            values << "%#{value.downcase}%"
          end
        end
        [conditions.join(' AND '), *values]
      end

      def index
        query = params[:query]
        field = params[:field]
        if query[0] == '*'
          search_str = query[1..-1] # Get the query string from the request
          puts "Search string: #{search_str}"

          query, *values = build_query(search_str)
          # TODO: optimize so joins are only when needed.
          @results = Applicant.joins(:schools, :toefl, :gre, :application_ielt)
                              .select('applicants.*, schools.*, toefls.*, gres.*, application_ielts.*')
                              .distinct
                              .where(query, *values)

          puts @results.inspect
        else
          # TODO: validate fields even tho already done on input.
          # todo: consider numerical feilds.
          # @results = Applicant.where("lower(#{field} LIKE ? %#{query.downcase}%)")
          @results = case field
                     when 'application_name'
                       Applicant.where('lower(application_name) LIKE ?', "%#{query.downcase}%")
                     when 'application_cas_id'
                       Applicant.where('application_cas_id LIKE ?', "%#{query}%")
                     when 'application_citizenship_country'
                       Applicant.where('lower(application_citizenship_country) LIKE ?', "%#{query.downcase}%")
                     when 'application_degree'
                       Applicant.where('lower(application_degree) LIKE ?', "%#{query.downcase}%")
                     else
                       Applicant.where('lower(application_name) LIKE ?', "%#{query.downcase}%")
                     end
        end

        puts @results
        render json: @results
      rescue ActiveRecord::StatementInvalid => e
        # Check for our custom error message, render a relevant JSON response
        if e.message.start_with?('Invalid column name:')
          render json: { error: e.message }, status: 400
        else
          # Handle other StatementInvalid errors here if necessary
        end

        # puts @results
        render json: @results
      end

      def parse_query_string(query_string)
        query_string.split(" ").map do |query|
          field, op, value = query.split(/(=|~|>|<)/)
          [field, op, value]
        end
      end

      def numeric?(string)
        true if Float(string) rescue false
      end

      private

      def authenticate_request
        token = request.headers["Authorization"].to_s.split(" ").last
        begin
          decoded_token = JWT.decode(token, JWT_PUBLIC_KEY, true, algorithm: JWT_ALGORITHM)
          puts "user_email: " + decoded_token[0]["user_email"]
        rescue JWT::DecodeError
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      end
    end
  end
end
