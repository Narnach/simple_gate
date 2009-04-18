class Router
  # Graph of server connections. 
  # It's a Hash of Arrays, which contains strings. Keys are server names with
  # a connection to other servers. Each of these servers is a string in the
  # associated Array.
  # An example graph with three servers 'foo', 'bar' and 'baz'.
  #
  #   router = Router.new
  #   router.paths = {
  #     'foo' => %w[bar],
  #     'bar' => ['baz']
  #   }
  #   router.find('foo', 'baz') #=> ['foo', 'bar', 'baz']
  attr_accessor :paths

  def initialize(paths={})
    @paths = paths
  end

  # A simple pathfinder. Returns a route as Array or nil.
  # Uses a very naieve depth-first recursive full-graph search to
  # find the shortest route.
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