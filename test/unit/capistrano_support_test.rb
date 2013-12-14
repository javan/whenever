require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/whenever/capistrano/v2/support")

class CapistranoSupportTestSubject
  include Whenever::CapistranoSupport
end

class CapistranoSupportTest < Test::Unit::TestCase
  context "when using capistrano support module" do
    setup do
      @capistrano = CapistranoSupportTestSubject.new
      configuration = mock
      configuration.stubs(:load).yields(@capistrano)
      Whenever::CapistranoSupport.load_into(configuration)
    end

    context "#whenever_options" do
      should "return fetch(:whenever_options)" do
        @capistrano.expects(:fetch).with(:whenever_options)
        @capistrano.whenever_options
      end
    end

    context "#whenever_roles with one role" do
      setup do
        @capistrano.stubs(:whenever_options).returns({:roles => :role1})
      end

      should "return whenever_options[:roles] as an array" do
        assert_equal [:role1], @capistrano.whenever_roles
      end
    end

    context "#whenever_roles with no defined roles" do
      setup do
        @capistrano.stubs(:whenever_options).returns({})
      end

      should "return an empty array" do
        assert_equal [], @capistrano.whenever_roles
      end
    end

    context "#whenever_servers" do
      should "return the list of servers returned by find_servers" do
        @capistrano.stubs(:whenever_options).returns({})
        @capistrano.stubs(:find_servers).returns([:server1, :server2])

        assert_equal [:server1, :server2], @capistrano.whenever_servers
      end
    end

    context "#whenever_server_roles" do
      setup do
        @mock_servers = ["foo", "bar"]
        @capistrano.stubs(:whenever_servers).returns(@mock_servers)
      end

      should "return a map of servers to their role(s)" do
        @capistrano.stubs(:whenever_roles).returns([:role1, :role2])
        @capistrano.stubs(:role_names_for_host).with("foo").returns([:role1])
        @capistrano.stubs(:role_names_for_host).with("bar").returns([:role2])
        assert_equal({"foo" => [:role1], "bar" => [:role2]}, @capistrano.whenever_server_roles)
      end

      should "exclude non-requested roles" do
        @capistrano.stubs(:whenever_roles).returns([:role1, :role2])
        @capistrano.stubs(:role_names_for_host).with("foo").returns([:role1, :role3])
        @capistrano.stubs(:role_names_for_host).with("bar").returns([:role2])
        assert_equal({"foo" => [:role1], "bar" => [:role2]}, @capistrano.whenever_server_roles)
      end

      should "include all roles for servers w/ >1 when they're requested" do
        @capistrano.stubs(:whenever_roles).returns([:role1, :role2, :role3])
        @capistrano.stubs(:role_names_for_host).with("foo").returns([:role1, :role3])
        @capistrano.stubs(:role_names_for_host).with("bar").returns([:role2])
        assert_equal({"foo" => [:role1, :role3], "bar" => [:role2]}, @capistrano.whenever_server_roles)
      end
    end

    context "#whenever_prepare_for_rollback" do
      should "set path to previous_release if there is a previous release" do
        args = {}
        @capistrano.stubs(:fetch).with(:previous_release).returns("/some/path/20121221010000")
        assert_equal({:path => "/some/path/20121221010000"}, @capistrano.whenever_prepare_for_rollback(args))
      end

      should "set path to release_path and flags to whenever_clear_flags if there is no previous release" do
        args = {}
        @capistrano.stubs(:fetch).with(:previous_release).returns(nil)
        @capistrano.stubs(:fetch).with(:release_path).returns("/some/path/20121221010000")
        @capistrano.stubs(:fetch).with(:whenever_clear_flags).returns("--clear-crontab whenever_identifier")
        assert_equal({:path => "/some/path/20121221010000", :flags => "--clear-crontab whenever_identifier"}, @capistrano.whenever_prepare_for_rollback(args))
      end
    end

    context "#whenever_run_commands" do
      should "require :command arg" do
        assert_raise ArgumentError do
          @capistrano.whenever_run_commands(:options => {}, :path => {}, :flags => {})
        end
      end

      should "require :path arg" do
        assert_raise ArgumentError do
          @capistrano.whenever_run_commands(:options => {}, :command => {}, :flags => {})
        end
      end

      should "require :flags arg" do
        assert_raise ArgumentError do
          @capistrano.whenever_run_commands(:options => {}, :path => {}, :command => {})
        end
      end

      context "with some servers defined" do
        setup do
          @mock_server1, @mock_server2, @mock_server3 = mock("Server1"), mock("Server2"), mock("Server3")
          @mock_server1.stubs(:host).returns("server1.foo.com")
          @mock_server2.stubs(:host).returns("server2.foo.com")
          @mock_server3.stubs(:host => "server3.foo.com", :port => 1022, :user => 'test')
          @mock_servers = [@mock_server1, @mock_server2]
        end

        should "call run for each host w/ appropriate role args" do
          @capistrano.stubs(:role_names_for_host).with(@mock_server1).returns([:role1])
          @capistrano.stubs(:role_names_for_host).with(@mock_server2).returns([:role2])
          @capistrano.stubs(:whenever_servers).returns(@mock_servers)
          roles = [:role1, :role2]
          @capistrano.stubs(:whenever_options).returns({:roles => roles})

          @capistrano.expects(:run).once.with('cd /foo/bar && whenever --flag1 --flag2 --roles role1', {:roles => roles, :hosts => @mock_server1})
          @capistrano.expects(:run).once.with('cd /foo/bar && whenever --flag1 --flag2 --roles role2', {:roles => roles, :hosts => @mock_server2})

          @capistrano.whenever_run_commands(:command => "whenever",
                                            :path => "/foo/bar",
                                            :flags => "--flag1 --flag2")
        end

        should "call run w/ all role args for servers w/ >1 role" do
          @capistrano.stubs(:role_names_for_host).with(@mock_server1).returns([:role1, :role3])
          @capistrano.stubs(:whenever_servers).returns([@mock_server1])
          roles = [:role1, :role2, :role3]
          @capistrano.stubs(:whenever_options).returns({:roles => roles})

          @capistrano.expects(:run).once.with('cd /foo/bar && whenever --flag1 --flag2 --roles role1,role3', {:roles => roles, :hosts => @mock_server1})

          @capistrano.whenever_run_commands(:command => "whenever",
                                            :path => "/foo/bar",
                                            :flags => "--flag1 --flag2")
        end

        should "call run w/ proper server options (port, user)" do
          @capistrano.stubs(:role_names_for_host).with(@mock_server3).returns([:role3])
          @capistrano.stubs(:whenever_servers).returns([@mock_server3])
          @capistrano.stubs(:whenever_options).returns({:roles => [:role3]})

          @capistrano.expects(:run).once.with do |command, options|
            options[:hosts].user == "test" && options[:hosts].port == 1022
          end

          @capistrano.whenever_run_commands(:command => "whenever",
                                            :path => "/foo/bar",
                                            :flags => "--flag1 --flag2")
        end
      end
    end
  end
end
