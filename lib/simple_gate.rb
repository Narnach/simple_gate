require 'rubygems'
require 'net/ssh'
require 'net/ssh/gateway'
require 'activesupport'
require 'simple_gate/server_definition'

class SimpleGate
  # Initialize a new SimpleGate
  # @param [Hash] options Hash with options to configure SimpleGate. Defaults to set :verbose to false.
  def initialize(options={})
    @options = {
      :verbose => false
    }.merge(options)
  end

  # Is the verbose option turned on?
  def verbose?
    @options[:verbose]
  end

  # Connect through a list of gateways to a target server.
  # Treats the last 'gateway' as the target server and the others as gateways.
  #
  # @param [Array] *gateways A list of gateway server names that can be found using ServerDefinition.find(). Should have at least one server name.
  # @yieldparam [Net::SSH::Connection::Session] session SSH Session to the target server.
  def through_to(*gateways)
    gateways = gateways.flatten
    raise ArgumentError.new("No target chosen") if gateways.size == 0
    target = ServerDefinition.find(gateways.pop)
    if gateways.size == 0
      target.connection_info do |host, user, options|
        Net::SSH.start(host,user,options) do |session|
          yield(session)
        end
      end
      return
    end
    through(gateways) do |gate|
      target.connection_info do |host, user, options|
        gate.ssh(host, user, options) do |session|
          yield(session)
        end
      end
    end
    nil
  end

  # Establish a series of gateways and yields the last one created.
  # Will automatically shut down gateway connections when the block closes.
  #
  # Most of the code was taken from Capistrano and then changed to work
  # outside of Capistrano.
  #
  # @param [Array] *gateways A list of gateway server names that can be found using ServerDefinition.find(). Should have at least one server name.
  # @yieldparam [Net::SSH::Gateway] gateway Gateway object of the last tunnel endpoint.
  def through(*gateways)
    Thread.abort_on_exception = true
    open_connections = []
    gateways = gateways.flatten.collect { |g| ServerDefinition.find(g) }
    tunnel = gateways[0].connection_info do |host, user, connect_options|
      STDERR.puts "Setting up tunnel #{gateways[0]}" if verbose?
      gw = Net::SSH::Gateway.new(host, user, connect_options)
      open_connections << gw
      gw
    end
    gateway = (gateways[1..-1]).inject(tunnel) do |tunnel, destination|
      STDERR.puts "Connecting to #{destination}" if verbose?
      tunnel_port = tunnel.open(destination.host, (destination.port || 22))
      localhost_options = {:user => destination.user, :port => tunnel_port, :password => destination.password}
      local_host = ServerDefinition.new("127.0.0.1", localhost_options)
      local_host.connection_info do |host, user, connect_options|
        STDERR.puts "Connecting using local info #{local_host}" if verbose?
        gw = Net::SSH::Gateway.new(host, user, connect_options)
        open_connections << gw
        gw
      end
    end
    yield(gateway)
  ensure
    while g = open_connections.pop
      g.shutdown!
    end
  end
end
