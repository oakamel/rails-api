class MessageWorker
  include Sidekiq::Worker

  def perform(content, number, chat_id, application_id)
    message = Message.new({
      "number": number,
      "content": content,
      "chat_id": chat_id,
      "application_id": application_id,
    })
    message.save
  end
end