module Whenever
  module CapistranoSupport
    def options
      fetch(:whenever_options)
    end

    def roles
      Array(options[:roles])
    end

    def servers
      find_servers(options)
    end

    def server_roles
      servers.inject({}) do |map, server|
        map[server] = role_names_for_host(server) & roles
        map
      end
    end

    def run_whenever_commands(args)
      unless [:command, :path, :flags].all? { |a| args.include?(a) }
        raise ArgumentError, ":command, :path, & :flags are required"
      end

      server_roles.each do |server, roles|
        roles_arg = roles.empty? ? "" : " --roles #{roles.join(',')}"

        command = "cd #{args[:path]} && #{args[:command]} #{args[:flags]}#{roles_arg}"
        run command, options.merge(:hosts => server.host)
      end
    end
  end
end
