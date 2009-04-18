require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'simple_gate/router'

describe Router do
  describe "#find" do
    it "should find a direct path from start to target" do
      router = Router.new({
        'start' => %w[target]
      })
      router.find('start','target').should == %w[start target]
    end

    it "should find a path from start to target through an intermediate node" do
      router = Router.new({
        'start' => %w[node],
        'node' => %w[target],
      })
      router.find('start','target').should == %w[start node target]
    end

    it "should find the shortest path from start to target" do
      router = Router.new({
        'start' => %w[node node2 node3],
        'node' => %w[node2],
        'node2' => %w[node3],
        'node3' => %w[target]
      })
      router.find('start','target').should == %w[start node3 target]
    end

    it 'should return nil if no route could be found' do
      router = Router.new({
        'start' => %w[],
      })
      router.find('start','target').should be_nil
    end

    it 'should return nil if the starting point can not be found' do
      router = Router.new({})
      router.find('start','target').should be_nil
    end

    it 'should not cause a stack overflow in a cyclical route graph' do
      router = Router.new({
        'start' => %w[node],
        'node' => %w[node target],
      })
      lambda {
        router.find('start','target').should == %w[start node target]
      }.should_not raise_error(SystemStackError)
    end
  end
end
