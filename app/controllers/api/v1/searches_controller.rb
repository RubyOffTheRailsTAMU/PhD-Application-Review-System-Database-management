module Api
    module V1
      class SearchesController < ApplicationController
        # You might want to skip CSRF token for API requests
        # todo: use verification? 
        skip_before_action :verify_authenticity_token
  
        def index
          query = params[:query]

          @results = Applicant.where("application_name LIKE ?", "%#{query}%")
          render json: @results
        end
      end
    end
  end
  