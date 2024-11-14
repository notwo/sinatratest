class CreateDelayedJobs < ActiveRecord::Migration[7.2]
  def self.up
    create_table :delayed_jobs do |t|
      t.integer  :priority, default: 0, null: false  # Higher priority jobs run first
      t.integer  :attempts, default: 0, null: false  # Number of attempts for this job
      t.text     :handler, null: false               # YAML-encoded string of the job object
      t.text     :last_error                         # Last error message from failed job
      t.datetime :run_at                             # When to run the job
      t.datetime :locked_at                          # When job was locked by a worker
      t.datetime :failed_at                          # When job last failed permanently
      t.string   :locked_by                          # Who is working on the job
      t.string   :queue                              # The name of the queue this job is in
      t.timestamps
    end

    add_index :delayed_jobs, [:priority, :run_at], name: 'delayed_jobs_priority'
  end

  def self.down
    drop_table :delayed_jobs
  end
end
