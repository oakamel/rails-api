require 'securerandom'

class ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :update, :destroy]

  # GET /applications
  def index
    @applications = Application.all.select "token, name"
    render json: @applications
  end

  # GET /applications/1
  def show
    if @application
      render json: { token: @application.token, name: @application.name }
    else
      render status: :not_found
    end
  end

  # POST /applications
  def create
    @application = Application.new(application_params)
    @application.token = SecureRandom.uuid

    if @application.save
      render json: @application, status: :created, location: @application
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /applications/1
  def update
    if @application.update(application_params)
      render json: @application
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/1
  def destroy
    @application.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Application.find_by(token: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def application_params
      params.require(:application).permit(:name)
    end
end
