# app/controllers/api/v1/applicants_controller.rb

module Api
  module V1
    class ApplicantsapiController < ApplicationController
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
        params.require(:applicant).permit(
          :applicant_cas_id,
          :applicant_name,
          :applicant_gender,
          :applicant_citizenship_country,
          :applicant_dob,
          :applicant_email,
          :applicant_degree,
          :applicant_submitted,
          :applicant_status,
          :applicant_research,
          :applicant_faculty
        )
      end
    end
  end
end
