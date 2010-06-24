module Whenever
  
  def self.cron(options)
    Whenever::JobList.new(options).generate_cron_output
  end
  
  def self.path
    Dir.pwd
  end

end