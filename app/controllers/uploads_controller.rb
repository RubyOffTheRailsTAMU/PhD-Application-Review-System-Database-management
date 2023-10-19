class UploadsController < ApplicationController
  # GET /uploads/new
  def new
  end

  # POST /uploads
  def create
    uploaded_file = params[:file]
    if uploaded_file
      filename = uploaded_file.original_filename
      File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
        file.write(uploaded_file.read)
        session[:excel_file_path] = file.path # Add file path to session. It will contain the file path from the last uploaded file.
      flash[:success] = 'File uploaded successfully!'
      redirect_to '/uploads/new'
    end
    else
      flash[:error] = 'Please choose a file to upload.'
      redirect_to '/uploads/new'
    end
  end
end

def flash_class(key)
  case key.to_sym
  when :success
    'alert-success'
  when :error
    'alert-error'
  else
    'alert-info' # Default class for other flash types
  end
end