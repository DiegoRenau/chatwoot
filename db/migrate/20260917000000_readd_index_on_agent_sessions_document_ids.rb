class ReaddIndexOnAgentSessionsDocumentIds < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  # Installs that created linked_buzzdesk_tickets under version 20260806000000
  # have that version recorded, so the upstream migration sharing it
  # (AddIndexOnAgentSessionsDocumentIds) is skipped as already run.
  def change
    add_index :agent_sessions, :document_ids, using: :gin, algorithm: :concurrently, if_not_exists: true
  end
end
