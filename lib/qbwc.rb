require 'qbwc/railtie'
require 'qbxml'

module QBWC
  autoload :Controller, 'qbwc/controller'
  autoload :Version, 'qbwc/version'
  autoload :Session, 'qbwc/session'
  autoload :Request, 'qbwc/request'
  autoload :QbwcJob, 'qbwc/qbwc_job'
  autoload :QbwcSession, 'qbwc/qbwc_session'
  autoload :ModelMethods, 'qbwc/model_methods'

  # Web connector login credentials
  mattr_accessor :username
  @@username = 'foo'
  mattr_accessor :password
  @@password = 'bar'

  # Full path to pompany file 
  mattr_accessor :company_file_path
  @@company_file_path = ""

  # Minimum quickbooks version required for use in qbxml requests
  mattr_accessor :min_version
  @@min_version = 3.0

  # App name in quickbooks file
  mattr_accessor :app_name
  @@app_name = Rails.application.class.parent_name

  # Quickbooks app url provided in qwc file, defaults to root_url + ''
  mattr_accessor :app_url
  @@app_url = nil

  # Quickbooks support url provided in qwc file, defaults to root_url
  mattr_accessor :support_site_url
  @@support_site_url = nil

  # Quickbooks owner id provided in qwc file
  mattr_accessor :owner_id
  @@owner_id = '{57F3B9B1-86F1-4fcc-B1EE-566DE1813D20}'

  # Quickbooks owner id provided in qwc file
  mattr_accessor :file_id
  @@file_id = '{57F3B9B1-86F1-4fcc-B1EE-566DE1813D20}'

  # How often to run web service (in minutes)
  mattr_accessor :minutes_to_run
  @@minutes_to_run = 5

  # Job definitions
  mattr_reader :jobs
  @@jobs = {}

  mattr_reader :on_error
  @@on_error = 'stopOnError'

  # Quickbooks Type (either :qb or :qbpos)
  mattr_reader :api, :parser
  @@api = :qb

  class << self

    def pending_jobs(user)
      QBWC::QbwcJob.where(processed: false, owner_id: user.id, owner_type: user.class.name)
    end

    def on_error=(reaction)
      raise 'Quickbooks type must be :qb or :qbpos' unless [:stop, :continue].include?(reaction)
      @@on_error = "stopOnError" if reaction == :stop
      @@on_error = "continueOnError" if reaction == :continue
    end

    def api=(api)
      raise 'Quickbooks type must be :qb or :qbpos' unless [:qb, :qbpos].include?(api)
      @@api = api
      @@parser = Qbxml.new(api)
    end

    # Allow configuration overrides
    def configure
      yield self
    end

  end

end
