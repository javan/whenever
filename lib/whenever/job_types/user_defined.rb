module Whenever
  module Job
    class UserDefined < Whenever::Job::Default
      attr_accessor :uses_bundler, :command, :environment
      
      def initialize(options={})
        super
        @uses_bundler = options[:uses_bundler]
        @command      = options[:command]
        @env          = options[:environment]
      end
      
      def to_options
        { :uses_bundler => uses_bundler, :command => command, :environment => environment }
      end

      def output
        out = []
        out << "cd #{File.join(@path)} &&"
        out << "bundle exec" if uses_bundler
        out << command
        out << "-e #{@environment}" if @env
        out << task.inspect
        out.join(" ")
      end
      
    end
  end
end