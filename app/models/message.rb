class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :application
  searchkick text_middle: [:content]
end
