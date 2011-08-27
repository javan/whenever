require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class BinaryTest < Test::Unit::TestCase
  
  context "whenever binary" do
    setup do
      @command = File.dirname(__FILE__) + "/../../bin/whenever"
    end

    should "handle --help" do
      output = collect_output(@command, '--help')
      assert output =~ /Usage:/
    end
    
    should "handle --version" do
      output = collect_output(@command, '--version')
      assert output =~ /Whenever v/
    end
  end
  
end
