class CreateChats < ActiveRecord::Migration[6.1]
  def change
    create_table :chats do |t|
      t.integer :number
      t.integer :messages_count
      t.references :application, null: false, foreign_key: true

      t.timestamps
    end
    add_index :chats, [:number, :application_id], unique: true
  end
end
