task :count_chats => [:environment] do
  dirty_applications = Redis.current.smembers "dirty_applications"
  Redis.current.del "dirty_applications"
  for dirty_application in dirty_applications do
    application_token = dirty_application
    chats_count = Redis.current.get application_token
    application = Application.find_by(token: application_token)
    application.chats_count = chats_count
    application.save
  end
end