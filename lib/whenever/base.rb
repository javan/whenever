module Whenever
  
  def self.cron(options)
    Whenever::JobList.new(options).generate_cron_output
  end
  
  def self.path
    if defined?(Rails)
      Rails.root.to_s
    elsif defined?(::Rails)
      ::Rails.root.to_s
    end
  end

end