module Api
    module V1
      class SearchesController < ApplicationController
        # You might want to skip CSRF token for API requests
        # todo: use verification? 
        skip_before_action :verify_authenticity_token
  
        def index
            query = params[:query]
            field = params[:field] 
            
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
            

            puts @results
            render json: @results
        end
      end
    end
  end
  