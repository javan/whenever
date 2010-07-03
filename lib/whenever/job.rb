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

        single_quote = "'"
        double_quote = '"'

        char_before = $`[-1..-1]
        char_after = $'[0..0]

        option = @options[key.sub(':', '').to_sym]

        if char_before == single_quote && char_after == single_quote
          escape_single_quotes(option)
        elsif char_after == double_quote && char_after == double_quote
          escape_double_quotes(option)
        else
          option
        end
      end
    end
    
  protected

    def escape_single_quotes(str)
      str.gsub(/'/) { "'\\''" }
    end
    
    def escape_double_quotes(str)
      str.gsub(/"/) { '\"' }
    end
    
  end
end
