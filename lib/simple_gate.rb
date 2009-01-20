require 'rubygems'
require 'net/ssh'
require 'net/ssh/gateway'
require 'activesupport'
require 'simple_gate/server_definition'

class SimpleGate
  # Most of the code was taken from Capistrano and adjusted to not need it.
  def through(*gateways)
    Thread.abort_on_exception = true
    @open_connections ||= []
    @gateways = gateways.flatten.collect { |g| ServerDefinition.find(g) }
    tunnel = @gateways[0].connection_info do |host, user, connect_options|
      puts "Setting up tunnel #{@gateways[0]}"
      gw = Net::SSH::Gateway.new(host, user, connect_options)
      @open_connections << gw
      gw
    end
    @gateway = (@gateways[1..-1]).inject(tunnel) do |tunnel, destination|
      puts "Connecting to #{destination}"
      tunnel_port = tunnel.open(destination.host, (destination.port || 22))
      localhost_options = {:user => destination.user, :port => tunnel_port, :password => destination.password}
      local_host = ServerDefinition.new("127.0.0.1", localhost_options)
      local_host.connection_info do |host, user, connect_options|
        puts "Connecting using local info #{local_host}"
        gw = Net::SSH::Gateway.new(host, user, connect_options)
        @open_connections << gw
        gw
      end
    end
    yield(@gateway)
  ensure
    while g = @open_connections.pop
      g.shutdown!
    end
  end
end
