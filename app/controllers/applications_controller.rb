require 'securerandom'

class ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :update, :destroy]

  # GET /applications
  def index
    @applications = Application.all.select "token, name, chats_count"
    render json: @applications
  end

  # GET /applications/1
  def show
    if @application
      render json: { token: @application.token, name: @application.name, chats_count: @application.chats_count }
    else
      render status: :not_found
    end
  end

  # POST /applications
  def create
    @application = Application.new(application_params)
    @application.token = SecureRandom.uuid
    @application.chats_count = 0

    if @application.save
      application_json = { token: @application.token, name: @application.name, chats_count: @application.chats_count }
      render json: application_json, status: :created, location: @application
    else
      render json: @application.errors, status: :internal_server_error
    end
  end

  # PATCH/PUT /applications/1
  def update
    if @application.update(application_params)
      application_json = { token: @application.token, name: @application.name, chats_count: @application.chats_count }
      render json: application_json
    else
      render json: @application.errors, status: :internal_server_error
    end
  end

  # # DELETE /applications/1
  # def destroy
  #   @application.destroy
  # end

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
