class Router
  # Graph of server connections.
  attr_accessor :paths

  # Create a new Router for a network of interconnected servers.
  # An example connections graph with three servers 'foo', 'bar' and 'baz':
  #
  #   router = Router.new
  #   # Define a graph: foo -> bar -> baz
  #   router.paths = {
  #     'foo' => %w[bar],
  #     'bar' => %w[baz]
  #   }
  #   router.find('foo', 'baz') #=> ['foo', 'bar', 'baz']
  # @param [Hash] paths Graph of server connections.
  #   It's a Hash of Arrays, which contains strings. Keys are server
  #   names with a connection to other servers. Each of these servers is a
  #   string in the associated Array.
  def initialize(paths={})
    @paths = paths
  end

  # A simple recursive pathfinder.
  # Uses a very naieve depth-first recursive full-graph search to
  # find the shortest route.
  # @param [String] start The node to start searching from for +target+.
  # @param [String] target The node to look for. Once it is found, return the shortest route to it.
  # @param [Array] current_route Internal variable that holds the route so far. Helps in preventing cyclic routes from being checked an infinite amount of times.
  # @return [Array] The sequence of nodes that connect +start+ to +target+.
  # @return [nil] When no route was found.
  def find(start, target, current_route = [])
    return [target] if start == target
    return nil unless paths.has_key?(start)

    # Map all possible paths to the target.
    # Skip nodes we have already visited
    next_nodes = paths[start] - current_route
    routes = next_nodes.map do |next_node|
      find(next_node, target, current_route + [start])
    end

    # Reduce the collection to the shortest path
    shortest_route = routes.compact.inject(nil) {|shortest,possibility|
      next possibility if shortest.nil?
      possibility.size < shortest.size ? possibility : shortest
    }
    return [start] + shortest_route if shortest_route
    nil
  end
end