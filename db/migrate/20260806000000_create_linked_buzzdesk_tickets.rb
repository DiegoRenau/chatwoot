class CreateLinkedBuzzdeskTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :linked_buzzdesk_tickets do |t|
      t.references :account, null: false, index: true
      t.references :conversation, null: false, index: true
      t.references :hook, null: false, index: true, foreign_key: { to_table: :integrations_hooks }
      t.string :ticket_id, null: false
      t.string :ticket_number, null: false
      t.string :title, null: false

      t.timestamps
    end

    add_index :linked_buzzdesk_tickets, [:conversation_id, :ticket_id],
              unique: true,
              name: 'idx_linked_buzzdesk_tickets_on_conversation_and_ticket'
  end
end
