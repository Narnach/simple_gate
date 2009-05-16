require 'yaml'
class ServerDefinition
  attr_accessor :host, :user, :port, :password, :auth_methods

  # Create a new ServerDefinition.
  #
  # @param [String] host Name of server.
  # @param [Hash] options Override the server's own configuration.
  # @option options [Integer] port (22) Server port
  # @option options [String] user SSH user
  # @option options [String] password SSH password
  def initialize(host, options = {})
    self.host = host
    self.user = options[:user]
    self.password = options[:password]
    self.port = options[:port] || 22
    self.auth_methods = options[:auth_methods] || %w[password keyboard-interactive]
  end

  # SSH options
  # @return [Hash]
  def options
    {
      :user => user,
      :password => password,
      :port => port,
      :auth_methods => auth_methods
    }
  end

  # Yield connection information.
  # @yieldparam [String] host SSH host
  # @yieldparam [String] user SSH user
  # @yieldparam [Hash] options SSH connection options
  # @see ServerDefinition#initialize
  # @see ServerDefinition#ssh_options
  def connection_info(&block)
    block.call(host, user, options)
  end

  # Represent server definition as URL-like string
  # @return [String]
  def to_s
    "#{user}:#{'*' * password.to_s.size}@#{host}:#{port}"
  end

  # Factory method that uses pre-defined server configurations.
  # @return [ServerDefinition]
  def self.lookup(server)
    server = servers[server]
    new(server['address'],{
      :user => server['username'],
      :password => server['password'],
      :port => server['port']
    })
  end

  # Factory method that chooses between a lookup and parse.
  # @param [String] server Server name or ssh string
  # @return [ServerDefinition]
  # @see ServerDefinition.lookup
  # @see ServerDefinition.parse
  def self.find(server)
    servers.has_key?(server) ? lookup(server) : parse(server)
  end

  # Factory method that parses a connection string.
  # @param [String] ssh_string String formatted as "user:password@host:port"
  # @return [ServerDefinition]
  def self.parse(ssh_string)
    user, password, host, port = ssh_string.match /\A(.*?):(.*?)@(.*?):(\d*?)\Z/
    new(host, :user => user, :password => password, :port => port)
  end

  class << self
    attr_accessor :servers

    # Access the pre-configured servers. ~/.servers.yml is parsed for this.
    # An example entry for the servers 'foobar' and 'barfoo' would look like:
    #   ---
    #   foobar:
    #     address: "127.0.0.1"
    #     username: "foo"
    #     password: "bar
    #     port: 22
    #   barfoo:
    #     address: "192.168.0.1"
    #     username: "bar"
    #     password: "foo
    #     port: 22
    #
    # Since the parsed Hash of servers is cached, a value can be stored and
    # the configuration file ignored if desired.
    # @return [Hash] Server name to server configuration pairs.
    def servers
      @servers ||= YAML.load_file(File.expand_path('~/.servers.yml'))
    end
  end
end