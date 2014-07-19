class IndexQbwcTables < ActiveRecord::Migration
  def change

    create_index :qbwc_sessions, [:owner_id, :owner_type]
    
    create_index :qbwc_sessions, :ticket, unique: true

    create_index :qbwc_jobs, [:owner_id, :owner_type, :id, :processed]
  end
end
