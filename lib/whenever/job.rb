module Whenever
  class Job
    
    attr_accessor :at, :output_redirection
  
    def initialize(options = {})
      @options = options
      
      @at                      = options[:at]
      @output_redirection      = options.has_key?(:output) ? options[:output] : :not_set
      @options[:environment] ||= :production
      @options[:path]        ||= Whenever.path
    end
  
    def output
      template = @options[:template].dup
      
      unless @options[:escape_quotes] === false
        template.sub!("':task'", %Q('#{@options[:task].gsub(/'/) { "'\''" }}'))
        template.sub!('":task"', %Q("#{@options[:task].gsub(/"/) { '\"' }}"))
      end
      
      template.gsub(/:\w+/) do |key|
        @options[key.sub(':', '').to_sym]
      end
    end
    
  end
end