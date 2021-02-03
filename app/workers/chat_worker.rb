class ChatWorker
  include Sidekiq::Worker

  def perform(number, application_id)
    chat = Chat.new({
      "number": number,
      "messages_count": 0,
      "application_id": application_id
    })
    chat.save
  end
end