class UploadsController < ApplicationController
  # GET /uploads/new
  def new
  end

  # POST /uploads
  def create
    uploaded_file = params[:file]
    if uploaded_file
      File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
        file.write(uploaded_file.read)
      end
      flash[:success] = 'File uploaded successfully!'
      puts flash[:success]
      # redirect_to '/uploads/new'
    else
      flash[:error] = 'Please choose a file to upload.'
      # redirect_to '/uploads/new'
    end
  end
end
