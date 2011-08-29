require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class BinaryTest < Test::Unit::TestCase
  
  context "whenever binary" do
    setup do
      root = File.dirname(__FILE__) + "/../.."
      @command = root + "/bin/whenever"
      lib = root + "/lib"
      opts = "-I#{lib} #{ENV['RUBYOPT']}"
      @env = {'RUBYOPT' => opts}
    end

    should "handle --help" do
      output = collect_output(@command, '--help', :env => @env)
      assert output =~ /Usage:/
    end
    
    should "handle --version" do
      output = collect_output(@command, '--version', :env => @env)
      assert output =~ /Whenever v/
    end
  end
  
end
