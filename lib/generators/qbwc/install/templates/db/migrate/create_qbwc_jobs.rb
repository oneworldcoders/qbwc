class CreateQbwcJobs < ActiveRecord::Migration
  def change
    create_table :qbwc_jobs do |t|
      t.integer :owner_id
      t.string  :owner_type
      t.string :klass
      t.integer :klass_id
      t.string :company, :limit => 1000
      t.boolean :processed, :null => false, :default => false

      t.timestamps
    end
  end
end
