module Whenever
  module Job
    class UserDefined < Whenever::Job::Default
      attr_accessor :uses_bundler, :command, :no_environment
      
      def initialize(options={})
        super
        @uses_bundler = options[:uses_bundler]
        @command      = options[:command]
        @no_environment = options[:no_environment]
      end
      
      def to_options
        { :uses_bundler => uses_bundler, :command => command, :no_environment => no_environment }
      end

      def output
        out = []
        out << "cd #{File.join(@path)} &&"
        out << "bundle exec" if uses_bundler
        out << command
        out << "-e #{@environment}" unless no_environment
        out << task.inspect
        out.join(" ")
      end
      
    end
  end
end