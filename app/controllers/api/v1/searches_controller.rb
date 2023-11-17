module Api
  module V1
    class SearchesController < ApplicationController
      # You might want to skip CSRF token for API requests
      # skip_before_action :verify_authenticity_token
      before_action :authenticate_request

      def index
        field = params[:field]
        unless Field.where(field_used: true, field_name: field).exists?
          render json: { error: "Invalid search field" }, status: :bad_request
          return
        end

        # Step 2: Retrieve the query parameter
        query = params[:query]

        # Step 3: Search in the Info table for matching records
        matched_cas_ids = Info.where("#{field} LIKE ?", "%#{query}%").pluck(:cas_id).uniq

        # # Step 4: Retrieve all related records from Info table grouped by cas_id
        # @results = matched_cas_ids.each_with_object({}) do |cas_id, grouped_results|
        #   grouped_results[cas_id] = Info.where(cas_id: cas_id).pluck(:field_id, :data_value)
        # end
        # @results = matched_cas_ids.each_with_object({}) do |cas_id, grouped_results|
        #   infos = Info.joins(:field) # Update this join as per your schema
        #               .where(cas_id: cas_id)
        #               .select("infos.data_value", "fields.field_name")
        #   grouped_results[cas_id] = infos.map { |info| { field_name: info.field_name, data: info.data_value } }
        # end
        @results = matched_cas_ids.map do |cas_id|
          infos = Info.joins(:field)
                      .where(cas_id: cas_id)
                      .select("infos.data_value", "fields.field_name")

          # Aggregate data for each cas_id
          aggregated_data = infos.each_with_object({}) do |info, hash|
            # key = "application_#{info.field_name}"
            # hash[key] = info.data_value
            hash[info.field_name] = info.data_value
          end
        end

        puts @results
        render json: @results
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
