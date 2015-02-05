module QBWC
  class QbwcSession < ActiveRecord::Base
    before_create :setup
    before_create :run_before_session_hooks

    belongs_to :previous_job, class_name: QBWC::QbwcJob, foreign_key: :prev_qbwc_job_id
    belongs_to :next_job,     class_name: QBWC::QbwcJob, foreign_key: :next_qbwc_job_id

    attr_accessor :response
    @@before_session_hooks = Set.new

    def self.add_before_session_hook(instance)
      @@before_session_hooks << instance.class
    end

    def current_request
      request = nil
      if job = self.next_job ||= next_job_in_queue
        obj = eval(job.klass).send(:find, job.klass_id)
        request = obj.qb_payload
        request = QBWC::Request.new(request)
        advance
      end
      request
    end

    def next_job_in_queue
      jobs = QBWC::QbwcJob.where(processed: false).order('id asc')
      jobs = jobs.where('id != ?', self.next_job.id) if self.next_job.present?
      jobs.limit(1).first
    end

    def advance
      self.prev_qbwc_job_id = next_job.id
      self.next_qbwc_job_id = next_job_in_queue.try(:id) || nil
      self.save!
    end

    def progress
      n_processed = QBWC::QbwcJob.where(processed: true).count.to_f
      total_jobs = QBWC::QbwcJob.count.to_f
      return 100 if n_processed == total_jobs
      ((n_processed / total_jobs)*100).to_i
    end

    def complete_session
      QBWC::QbwcJob.where(processed: true).destroy_all
      self.destroy
    end

    private
    def setup
      self.ticket = Digest::SHA1.hexdigest("#{Rails.application.config.secret_token}#{Time.now.to_i}")
    end

    def run_before_session_hooks
      @@before_session_hooks.each do |klass|
        klass.before_qb_session
      end
    end
  end
end
