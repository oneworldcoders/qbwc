class CreateQbwcSessions < ActiveRecord::Migration
  def change
    create_table :qbwc_sessions do |t|
      t.integer :owner_id
      t.string  :owner_type
      t.string :ticket
      t.string :user
      t.string :company, :limit => 1000
      t.integer :total_requests, :null => false, :default => 0
      t.integer :prev_qbwc_job_id
      t.integer :next_qbwc_job_id
      t.string :error, :limit => 1000

      t.timestamps
    end
  end
end
