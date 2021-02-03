class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.integer :number
      t.text :content
      t.references :chat, null: false, foreign_key: true
      t.references :application, null: false, foreign_key: true

      t.timestamps
    end
    add_index :messages, [:number, :application_id, :chat_id], unique: true
  end
end
