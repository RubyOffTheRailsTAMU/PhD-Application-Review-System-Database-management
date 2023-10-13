module Api
  module V1
    class ApplicantsapiController < ApplicationController
      skip_before_action :verify_authenticity_token
      def index
        applicants = Applicant.all
        render json: applicants
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
