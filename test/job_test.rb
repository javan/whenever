require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class JobTest < Test::Unit::TestCase
  
  context "A Job" do
    should "output the :task" do
      job = new_job(:template => ":task", :task => 'abc123')
      assert_equal %q(abc123), job.output
    end
    
    should "output the :task if it's in single quotes" do
      job = new_job(:template => "':task'", :task => 'abc123')
      assert_equal %q('abc123'), job.output
    end
    
    should "output the :task if it's in double quotes" do
      job = new_job(:template => '":task"', :task => 'abc123')
      assert_equal %q("abc123"), job.output
    end
    
    should "output escaped single quotes in when it's wrapped in them" do
      job = new_job(
        :template => "before ':foo' after",
        :foo => "quote -> ' <- quote"
      )
      assert_equal %q(before 'quote -> '\'' <- quote' after), job.output
    end
    
    should "output escaped double quotes when it's wrapped in them" do
      job = new_job(
        :template => 'before ":foo" after',
        :foo => 'quote -> " <- quote'
      )
      assert_equal %q(before "quote -> \" <- quote" after), job.output
    end
  end

private

  def new_job(options)
    Whenever::Job.new(options)
  end
  
end
