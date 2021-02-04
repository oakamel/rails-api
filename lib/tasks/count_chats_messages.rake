task :count_chats_messages => [:environment] do
  dirty_chats = Redis.current.smembers "dirty_chats"
  Redis.current.del "dirty_chats"
  for dirty_chat in dirty_chats do
    dirty_chat_split = dirty_chat.split "_"
    application_token = dirty_chat_split[0]
    chat_number = dirty_chat_split[1]
    messages_count = Redis.current.get dirty_chat
    application = Application.find_by(token: application_token)
    chat = Chat.find_by(application_id: application.id, number: chat_number)
    chat.messages_count = messages_count
    chat.save
  end
end