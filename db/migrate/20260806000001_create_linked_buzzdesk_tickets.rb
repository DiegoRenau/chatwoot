class CreateLinkedBuzzdeskTickets < ActiveRecord::Migration[7.1]
  def change
    # Installs that ran this migration under its previous version number
    # (20260806000000, which collided with an upstream 4.17.x migration)
    # already have the table, and see the renumbered file as pending.
    return if table_exists?(:linked_buzzdesk_tickets)

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
