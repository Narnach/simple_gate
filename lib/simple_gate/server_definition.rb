require 'yaml'
class ServerDefinition
  attr_accessor :host, :user, :options, :port, :password
  
  def initialize(host, options = {})
    @options = {:port => 22}.merge(options)
    self.host = host
    self.user = @options[:user]
    self.password = @options[:password]
    self.port = @options[:port]
  end
  
  def user=(user)
    options[:user] = user
    @user=user
  end

  def port=(port)
    options[:port] = port
    @port=port
  end

  def password=(password)
    options[:password] = password
    @password=password
  end

  def connection_info(&block)
    block.call(host, user, options.merge(ssh_options))
  end
  
  def ssh_options
    {
      :auth_methods => %w[password keyboard-interactive]
    }
  end
  
  def to_s
    "#{user}:#{'*' * password.to_s.size}@#{host}:#{port}"
  end
  
  def self.lookup(server)
    server = servers[server]
    new(server['address'],{ 
      :user => server['username'],
      :password => server['password'], 
      :port => server['port']
    })
  end
  
  def self.find(server)
    servers.has_key?(server) ? lookup(server) : parse(server)
  end
  
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
    def servers
      @servers ||= YAML.load_file(File.expand_path('~/.servers.yml'))
    end
  end
end