require 'redis'

class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy]

  # GET /messages
  def index
    @messages = Message.all

    render json: @messages
  end

  # GET /messages/1
  def show
    # Message.reindex
    products = Message.search "kazx", match: :text_middle
    puts "------------------"
    # puts products
    products.each do |product|
      puts product.content
    end
    render json: @message
  end

  def search
    messages = Message.search params[:content], match: :text_middle
    render json: messages
  end

  # POST /messages
  def create
    # @message = Message.new(message_params)

    # if @message.save
    #   render json: @message, status: :created, location: @message
    # else
    #   render json: @message.errors, status: :unprocessable_entity
    # end
    content = params[:content] 
    application_token = params[:application_token]
    chat_number = params[:chat_number]
    @application = Application.find_by(token: application_token)
    @chat = Chat.find_by(application_id: @application.id, number: chat_number)
    return render status: :unprocessable_entity if !@application || !@chat
    token_chat_key = application_token + "_" + chat_number
    message_number = Redis.current.incr token_chat_key
    Redis.current.sadd "dirty_chats", token_chat_key 

    MessageWorker.perform_async(content, message_number, @application.id, @chat.id)
    render json: {
      "application_token": application_token, 
      "chat_number": chat_number, 
      "message_number": message_number
    }, status: :created
  end

  # PATCH/PUT /messages/1
  def update
    if @message.update(message_params)
      render json: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /messages/1
  def destroy
    @message.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:number, :content, :chat_id, :application_id)
    end
end
