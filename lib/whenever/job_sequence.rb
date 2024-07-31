require 'shellwords'

module Whenever
  class JobSequence
    attr_reader :at, :roles, :mailto

    def initialize(jobs, options = {})
      validate!(jobs)

      @jobs     = jobs
      @options  = options
      @at       = options.fetch(:at, primary_job.at)
      @mailto   = options.fetch(:mailto, primary_job.mailto || :default_mailto)
      @roles    = Array(options.delete(:roles), *primary_job.roles)
    end

    def output
      @jobs.map { |job| [job.output, job.halt_sequence_on_failure ?  ' && ' : ' ; '] }.flatten[0..-2].join
    end

    def has_role?(role)
      roles.empty? || roles.include?(role)
    end

  private

    def primary_job
      @jobs.first
    end

    def validate!(jobs)
      raise ArgumentError, "Jobs in a sequence don't support different `at` values" if jobs.map(&:at).uniq.count > 1
    end
  end
end
