class FieldsController < ApplicationController
  # GET /fields
  def index
    @fields = Field.all
  end

  # GET /fields/1
  def show
    @field = Field.find(params[:id])
  end

  # GET /fields/new
  def new
    @field = Field.new
  end

  # GET /fields/1/edit
  def edit
    @field = Field.find(params[:id])
  end

  # POST /fields
  def create
    @field = Field.new(field_params)
    if @field.save
      redirect_to @field
    else
      render :new
    end
  end

  # PATCH/PUT /fields/1
  def update
    @field = Field.find(params[:id])
    if @field.update(field_params)
      redirect_to @field
    else
      render :edit
    end
  end

  # DELETE /fields/1
  def destroy
    @field = Field.find(params[:id])
    @field.destroy
    redirect_to fields_url
  end

  private

  # Only allow a list of trusted parameters through.
  def field_params
    params.require(:field).permit(:field_name, :field_alias)
  end
end
