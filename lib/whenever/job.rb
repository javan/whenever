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
      
      template.gsub(/:\w+/) do |key|
        if key == ':task' && template.index("':task'")
          escape_single_quotes(@options[:task])
        elsif key == ':task' && template.index('":task"')
          escape_double_quotes(@options[:task])
        else
          @options[key.sub(':', '').to_sym]
        end
      end
    end
    
  protected
  
    def escape_single_quotes(str)
      str.gsub(/'/, %q('\''))
    end
    
    def escape_double_quotes(str)
      str.gsub(/"/, %q(\"))
    end
    
  end
end