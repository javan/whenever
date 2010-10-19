module Whenever
  class Job
    
    attr_reader :at
  
    def initialize(options = {})
      @options = options
      
      @at                      = options[:at]
      @options[:output]        = Whenever::Output::Redirection.new(options[:output]).to_s if options.has_key?(:output)
      @options[:environment] ||= :production
      @options[:path]        ||= Whenever.path
    end
  
    def output
      @options[:template].dup.gsub(/:\w+/) do |key|
        before_and_after = [$`[-1..-1], $'[0..0]]
        option = @options[key.sub(':', '').to_sym]

        if before_and_after.all? { |c| c == "'" }
          escape_single_quotes(option)
        elsif before_and_after.all? { |c| c == '"' }
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
