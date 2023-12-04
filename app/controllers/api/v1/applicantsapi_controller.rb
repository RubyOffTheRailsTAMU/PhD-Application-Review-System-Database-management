module Api
  module V1
    class ApplicantsapiController < ApplicationController
      skip_before_action :verify_authenticity_token
      def index
        applicants = Applicant.all
        render json: applicants
      end

      def return_PDF
        pdf_files = Dir.glob(Rails.root.join("public", "uploads", "PDF", "*.pdf"))
        results = []
        cas_id = params[:cas_id]
        pdf_files.each do |pdf_file|
          #check if a pdf file contains CAS ID
          if pdf_file.include?(cas_id)
            results << pdf_file
          end
        end
        if results.any?
          first_result = results.first
          encoded_result = Base64.strict_encode64(first_result.to_json)
        else
          encoded_result = "error"
        end
        render json: {"pdf_file": encoded_result}
      end

      def show
        applicant = Applicant.find(params[:id])
        render json: applicant
      end

      def create
        applicant = Applicant.new(applicant_params)
        if applicant.save
          render json: applicant, status: :created
        else
          render json: applicant.errors, status: :unprocessable_entity
        end
      end

      def update
        applicant = Applicant.find(params[:id])
        if applicant.update(applicant_params)
          render json: applicant
        else
          render json: applicant.errors, status: :unprocessable_entity
        end
      end

      def destroy
        applicant = Applicant.find(params[:id])
        applicant.destroy
        head :no_content
      end

      private

      def applicant_params
        params.require(:applicantsapi).permit(
          :application_cas_id,
          :application_name,
          :application_gender,
          :application_citizenship_country,
          :application_dob,
          :application_email,
          :application_degree,
          :application_submitted,
          :application_status,
          :application_research,
          :application_faculty
        )
      end
    end
  end
end
