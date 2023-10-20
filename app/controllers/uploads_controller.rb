class UploadsController < ApplicationController
  # GET /uploads/new
  def new
  end

  # POST /uploads
  def create
    uploaded_file = params[:file]
    #check if file is of format .xlsx, .xls or .csv
    if uploaded_file && (uploaded_file.content_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || uploaded_file.content_type == 'application/vnd.ms-excel' || uploaded_file.content_type == 'text/csv')
      filename = uploaded_file.original_filename
      File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
        file.write(uploaded_file.read)
        session[:excel_file_path] = file.path # Add file path to session. It will contain the file path from the last uploaded file.
        #flash[:success] = 'File uploaded successfully!'
        redirect_to '/applicants/savedata'
        #redirect_to '/applicants/savedata', format: :json
      end
    elsif uploaded_file && (uploaded_file.content_type != 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || uploaded_file.content_type != 'application/vnd.ms-excel' || uploaded_file.content_type != 'text/csv')
      flash[:error] = 'Invalid file format! Please upload a file of type .xlsx, .xls or .csv'
      redirect_to '/uploads/new'
    else
      flash[:error] = 'Please upload a file'
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