require 'redis'

class ChatsController < ApplicationController
  before_action :set_chat, only: [:show, :update, :destroy]

  # GET /chats
  def index
    @chats = Chat.all

    render json: @chats
  end

  # GET /chats/1
  def show
    render json: @chat
  end

  # POST /chats
  def create
    # @chat = Chat.new(chat_params)

    # if @chat.save
    #   render json: @chat, status: :created, location: @chat
    # else
    #   render json: @chat.errors, status: :unprocessable_entity
    # end
    application_token = params[:application_token]
    @application = Application.find_by(token: application_token)
    return render status: :unprocessable_entity if !@application
    chat_number = Redis.current.incr application_token
    ChatWorker.perform_async(chat_number, @application.id)
    render json: {"application_id": application_token, "chat_number": chat_number}, status: :created
  end

  # PATCH/PUT /chats/1
  def update
    if @chat.update(chat_params)
      render json: @chat
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # DELETE /chats/1
  def destroy
    @chat.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = Chat.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def chat_params
      params.require(:chat).permit(:number, :application_token)
    end
end
