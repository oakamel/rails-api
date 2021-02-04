require 'redis'

class ChatsController < ApplicationController
  before_action :set_chat, only: [:show, :update, :destroy]

  # GET /chats
  def index
    application = Application.find_by(token: params[:application_id])
    return render(json: {error: "application not found"}, status: :not_found) if !application
    @chats = Chat.where(application_id: application.id)
    chats_list = []
    for chat in @chats do
      chats_list.append(get_chat_hash application, chat)
    end
    render json: chats_list
  end

  # GET /chats/1
  def show
    render json: get_chat_hash(@application, @chat)
  end

  # POST /chats
  def create
    # get application
    application = Application.find_by(token: params[:application_id])
    return render(json: {error: "application not found"}, status: :not_found) if !application

    # generate chat number
    chat_number = Redis.current.incr application.token
    
    # mark application as dirty
    Redis.current.sadd "dirty_applications", application.token 

    # queue chat creation job
    ChatWorker.perform_async(chat_number, application.id)
    
    render json: {"application_token": application.token, "number": chat_number}, status: :created
  end

  # # PATCH/PUT /chats/1
  # def update
  #   if @chat.update(chat_params)
  #     render json: @chat
  #   else
  #     render json: @chat.errors, status: :unprocessable_entity
  #   end
  # end

  # # DELETE /chats/1
  # def destroy
  #   @chat.destroy
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @application = Application.find_by(token: params[:application_id])
      return render(json: {error: "application not found"}, status: :not_found) if !@application
      @chat = Chat.find_by(application_id: @application.id, number: params[:id])
      return render(json: {error: "chat not found"}, status: :not_found) if !@chat 
    end

    def get_chat_hash(application, chat)
      {
        application_token: application.token,
        number: chat.number,
        messages_count: chat.messages_count
      }
    end

    # Only allow a list of trusted parameters through.
    def chat_params
      params.require(:chat).permit(:number, :application_token)
    end
end
