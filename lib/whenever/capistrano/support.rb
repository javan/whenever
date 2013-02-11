module Whenever
  module CapistranoSupport
    def self.load_into(capistrano_configuration)
      capistrano_configuration.load do

        def whenever_options
          fetch(:whenever_options)
        end

        def whenever_roles
          Array(whenever_options[:roles])
        end

        def whenever_servers
          find_servers(whenever_options)
        end

        def whenever_server_roles
          whenever_servers.inject({}) do |map, server|
            map[server] = role_names_for_host(server) & whenever_roles
            map
          end
        end

        def whenever_prepare_for_rollback args
          if fetch(:previous_release)
            # rollback to the previous release's crontab
            args[:path] = fetch(:previous_release)
          else
            # clear the crontab if no previous release
            args[:path]  = fetch(:release_path)
            args[:flags] = fetch(:whenever_clear_flags)
          end
          args
        end

        def whenever_run_commands(args)
          unless [:command, :path, :flags].all? { |a| args.include?(a) }
            raise ArgumentError, ":command, :path, & :flags are required"
          end

          whenever_server_roles.each do |server, roles|
            roles_arg = roles.empty? ? "" : " --roles #{roles.join(',')}"

            command = "cd #{args[:path]} && #{args[:command]} #{args[:flags]}#{roles_arg}"
            run command, whenever_options.merge(:hosts => server)
          end
        end

      end
    end
  end
end
