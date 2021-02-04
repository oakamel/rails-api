require 'redis'

class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy]

  # GET /messages
  def index
    application = Application.find_by(token: params[:application_id])
    return render(json: {error: "application not found"}, status: :not_found) if !application
    chat = Chat.find_by(application_id: application.id, number: params[:chat_id])
    return render(json: {error: "chat not found"}, status: :not_found) if !chat
    @messages = Message.where(chat_id: chat.id)
    messages_list = []
    for message in @messages do
      messages_list.append(get_message_hash(application, chat, message))
    end
    render json: messages_list
  end

  # GET /messages/1
  def show
    render json: get_message_hash(@application, @chat, @message)
  end

  def search
    messages = Message.search params[:query], match: :text_middle
    messages_list = []
    for message in messages do
      chat = Chat.find(message.chat_id)
      application = Application.find(chat.application_id)
      messages_list.append(get_message_hash(application, chat, message))
    end
    render json: messages_list
  end

  # POST /messages
  def create
    # get application and chat
    application = Application.find_by(token: params[:application_id])
    return render(json: {error: "application not found"}, status: :not_found) if !application
    chat = Chat.find_by(application_id: application.id, number: params[:chat_id])
    return render(json: {error: "chat not found"}, status: :not_found) if !chat

    # generate message number
    token_chat_key = application.token + "_" + chat.number.to_s
    message_number = Redis.current.incr token_chat_key

    # mark chat as dirty
    Redis.current.sadd "dirty_chats", token_chat_key 
    
    # queue message creation job
    content = params[:content]
    MessageWorker.perform_async(content, message_number, application.id, chat.id)

    render json: {
      "application_token": application.token, 
      "chat_number": chat.number, 
      "number": message_number,
      "content": content
    }, status: :created
  end

  # # PATCH/PUT /messages/1
  # def update
  #   if @message.update(message_params)
  #     render json: @message
  #   else
  #     render json: @message.errors, status: :unprocessable_entity
  #   end
  # end

  # # DELETE /messages/1
  # def destroy
  #   @message.destroy
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @application = Application.find_by(token: params[:application_id])
      return render(json: {error: "application not found"}, status: :not_found) if !@application
      @chat = Chat.find_by(application_id: @application.id, number: params[:chat_id])
      return render(json: {error: "chat not found"}, status: :not_found) if !@chat
      @message = Message.find_by(chat_id: @chat.id, number: params[:id])
      return render(json: {error: "message not found"}, status: :not_found) if !@message
    end

    def get_message_hash(application, chat, message)
      {
        application_token: application.token,
        chat_number: chat.number,
        number: message.number,
        content: message.content
      }
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:number, :content, :chat_id, :application_id)
    end
end
