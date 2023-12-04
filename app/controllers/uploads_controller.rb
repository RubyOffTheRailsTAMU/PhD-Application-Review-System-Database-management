require 'zip'
require 'fileutils'
class UploadsController < ApplicationController
  before_action :require_user
  # GET /uploads/new
  def new
  end

  # POST /uploads
  def create
    uploaded_file = params[:file]
    #check if file is of format .xlsx, .xls or .csv
    if uploaded_file && (
      uploaded_file.content_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ||
      uploaded_file.content_type == "application/vnd.ms-excel" ||
      uploaded_file.content_type == "text/csv" ||
      uploaded_file.content_type == "application/zip"
    )      
      filename = uploaded_file.original_filename
    if uploaded_file.content_type == "application/zip"
      Zip::File.open(uploaded_file.path) do |zip_file|
        zip_file.each do |entry|
          next if entry.name.downcase.include?('__macosx')
          filename = entry.name
          puts "Extracting #{filename}"
          #add datetime to filename to avoid overwriting
          filename = DateTime.now.strftime('%Y%m%d%H%M%S') + filename
          #extract file
          entry.extract(Rails.root.join("public", "uploads", "PDF", filename))
        end
      end
    else
      File.open(Rails.root.join("public", "uploads", filename), "wb") do |file|
        file.write(uploaded_file.read)
        session[:excel_file_path] = file.path # Add file path to session. It will contain the file path from the last uploaded file.
        #flash[:success] = 'File uploaded successfully!'
        # redirect_to '/applicants/savedata'
        redirect_to "/applicants/uploads_handler"
      end
    end
    elsif uploaded_file && (uploaded_file.content_type != "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" || uploaded_file.content_type != "application/vnd.ms-excel" || uploaded_file.content_type != "text/csv")
      flash[:error] = "Invalid file format! Please upload a file of type .xlsx, .xls or .csv"
      redirect_to "/uploads/new"
    else
      flash[:error] = "No file selected. Please choose a file."
      redirect_to "/uploads/new"
    end
  end
end

def flash_class(key)
  case key.to_sym
  when :success
    "alert-success"
  when :error
    "alert-error"
  else
    "alert-info" # Default class for other flash types
  end
end
