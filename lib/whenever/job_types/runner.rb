module Whenever
  module Job
    class Runner < Whenever::Job::Default

      def output
        path_required
        %Q(cd #{File.join(@path)} && script/runner -e #{@environment} #{task.inspect})
      end
      
    end
  end
end
