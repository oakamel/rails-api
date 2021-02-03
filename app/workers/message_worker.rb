class MessageWorker
  include Sidekiq::Worker

  def perform(content, number, application_id, chat_id)
    message = Message.new({
      "number": number,
      "content": content,
      "application_id": application_id,
      "chat_id": chat_id
    })
    message.save
  end
end