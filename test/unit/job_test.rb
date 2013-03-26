require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class JobTest < Test::Unit::TestCase

  context "A Job" do
    should "return the :at set when #at is called" do
      assert_equal 'foo', new_job(:at => 'foo').at
    end

    should "return the :roles set when #roles is called" do
      assert_equal ['foo', 'bar'], new_job(:roles => ['foo', 'bar']).roles
    end

    should "return whether it has a role from #has_role?" do
      assert new_job(:roles => 'foo').has_role?('foo')
      assert_equal false, new_job(:roles => 'bar').has_role?('foo')
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

    should "not substitute parameters for which no value is set" do
      assert_equal 'Hello :world', new_job(:template => ':matching :world', :matching => 'Hello').output
    end

    should "escape the :path" do
      assert_equal '/my/spacey\ path', new_job(:template => ':path', :path => '/my/spacey path').output
    end

    should "escape percent signs" do
      job = new_job(
        :template => "before :foo after",
        :foo => "percent -> % <- percent"
      )
      assert_equal %q(before percent -> \% <- percent after), job.output
    end

    should "assume percent signs are not already escaped" do
      job = new_job(
        :template => "before :foo after",
        :foo => %q(percent preceded by a backslash -> \% <-)
      )
      assert_equal %q(before percent preceded by a backslash -> \\\% <- after), job.output
    end

    should "reject newlines" do
      job = new_job(
        :template => "before :foo after",
        :foo => "newline -> \n <- newline"
      )
      assert_raise ArgumentError do
        job.output
      end
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

  context "A Job with a Proc template builder" do
    should "use template builder in favor of string template" do
      job = new_job(:template => 'foo', :job_template => 'left ":job" right') { 'bar' }
      assert_equal %q(left "bar" right), job.output
    end

    should "replace options in the builder's result" do
      job = new_job(:task => 'foo', :hip => 'hop', :job_template => 'left ":job" right') { 'some :hip :task' }
      assert_equal %q(left "some hop foo" right), job.output
    end

    should "chain the passed tasks" do
      job = new_job(:job_template => 'left ":job" right', :tasks => ["def", "abc"]) do |options|
        break if !options[:tasks] || options[:tasks].empty?
        taskcmds = options[:tasks].map { |task| "bundle exec rake #{task}" }
        "cd :_path && " << taskcmds.join(" && ")
      end
      assert_equal %q(left "cd :_path && bundle exec rake def && bundle exec rake abc" right), job.output
    end
  end

private

  def new_job(options={}, &block)
    Whenever::Job.new(options, &block)
  end

end
