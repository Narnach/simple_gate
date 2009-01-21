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
  # The graph must be acyclical or it will loop forever.
  def find(start, target)
    if start == target
      return [target]
    end
    if paths.has_key?(start)
      # Map all possible paths to the target
      routes = paths[start].map do |next_node|
        find(next_node, target)
      end
      # Reduce the collection to the shortest path
      shortest_route = routes.compact.inject(nil) {|shortest,possibility|
        next possibility if shortest.nil?
        possibility.size < shortest.size ? possibility : shortest
      }
      if shortest_route
        return [start] + shortest_route
      else
        return nil
      end
    end
    return nil
  end
end