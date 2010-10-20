require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class JobTest < Test::Unit::TestCase
  
  context "A Job" do
    should "return the :at set when #at is called" do
      assert_equal 'foo', new_job(:at => 'foo').at
    end
    
    should "substitute the :task when #output is called" do
      job = new_job(:template => ":task", :task => 'abc123')
      assert_equal 'abc123', job.output
    end
    
    should "substitute the :path when #output is called" do
      assert_equal 'foo', new_job(:template => ':path', :path => 'foo').output
    end
    
    should "substitute the :path with the default Whenever.path if none is provided when #output is called" do
      Whenever.expects(:path).returns('/my/path')
      assert_equal '/my/path', new_job(:template => ':path').output
    end
  end

  
  context "A Job with quotes" do
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
  
  context "A Job with a job_template" do
    should "use the job template" do
      job = new_job(:template => ':task', :task => 'abc123', :job_template => 'left :job right')
      assert_equal 'left abc123 right', job.output
    end
    
    should "escape single quotes" do
      job = new_job(:template => "before ':task' after", :task => "quote -> ' <- quote", :job_template => "left ':job' right")
      assert_equal %q(left 'before '\''quote -> '\\''\\'\\'''\\'' <- quote'\'' after' right), job.output
    end
    
    should "escape double quotes" do
      job = new_job(:template => 'before ":task" after', :task => 'quote -> " <- quote', :job_template => 'left ":job" right')
      assert_equal %q(left "before \"quote -> \\\" <- quote\" after" right), job.output
    end
  end

private

  def new_job(options={})
    Whenever::Job.new(options)
  end
  
end
