module Whenever
  module Job
    class UserDefined < Whenever::Job::Default
      attr_accessor :command, :settings
      
      def initialize(opts={})
        super
        @command = opts[:command]
        @settings = opts[:settings] ||= {}
      end
      
      def to_options
        { :command => command, :settings => settings }
      end

      def output
        [ cd_path, bundler, command, app_environment, quoted_task ].compact.join(" ")
      end
      
      private
      
        def cd_path
          parse_setting :path, "cd #{settings[:path]} &&", "cd #{File.join(@path)} &&"
        end
        
        def app_environment
          parse_setting :environment, "-e #{settings[:environment]}", "-e #{@environment}"
        end
        
        def bundler
          "bundle exec" if settings[:use_bundler]
        end
        
        def parse_setting(name, with_option, without_option)
          if settings.has_key? name
            with_option if settings[name]
          else
            without_option
          end
        end
        
        def quoted_task
          settings[:quote_task] == false ? task : task.inspect
        end
      
    end
  end
end