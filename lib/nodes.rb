require 'filters'
require 'context'

module Hiromi

  class NodeList

    attr_accessor :src

    def initialize
      self.src = []
    end

    def <<(node)
      self.src << node
    end

    def concat(list)
      self.src.concat(list.src)
    end

    def override_node(target, override_with)
      index = self.src.find_index(target)
      self.src[index] = override_with
    end

    def contains(node)
      self.src.find {|src_node| src_node.is_a?(BlockNode) && src_node.block_name == node.block_name}
    end

    def render(context)
      compiled_string = StringIO.new

      self.src.each do |node|
        compiled_string << node.render(context)
      end

      compiled_string.string
    end

  end

  class Node

    attr_accessor :contents

    def initialize(contents)
      self.contents = contents
    end

  end

  class StaticNode < Node

    def render(context)
      self.contents
    end

  end

  class BlockNode < Node

    attr_accessor :block_name, :node_list

    def initialize(block_name, node_list)
      self.block_name = block_name
      self.node_list = node_list
    end

    def self.create(parser, token)
      # get the block name
      block_name = token.contents.split[1]

      current_state = parser.in_extends_state
      parser.in_extends_state = false
      node_list = parser.parse(['endblock'])
      parser.in_extends_state = current_state

      # Token should be the endblock
      token = parser.next_token()

      BlockNode.new(block_name, node_list)
    end

    def render(context)
      return self.node_list.render(context)
    end

  end

  class VariableNode < Node

    def initialize(contents)
      super(contents)
      # if contents !~ /^\s*\w+\s*$/
        # raise TemplateSyntaxError
      # end
    end

    def render(context)
      parts = self.contents.split('|')
      var = parts[0]
      filters = parts[1..-1].map {|filter_type| create_filter(filter_type) }
      apply_filters(context.get(InvocationResolver.new(var)), filters)
    end

    #Refactor to use inject
    def apply_filters(var, filters)
      filters.each do |filter|
        var = filter.execute(var)
      end
      var
    end

    def create_filter(filter_type)
      return LowerFilter.new if filter_type == 'lower'
      return LengthFilter.new if filter_type == 'length'
    end

  end

  class IfNode < Node

    attr_accessor :node_list_true, :node_list_false, :var

    def initialize(var, node_list_true, node_list_false=nil)
      self.var = var
      self.node_list_true = node_list_true
      self.node_list_false = node_list_false
    end

    def render(context)
      if self.var.eval(context)
        return self.node_list_true.render(context)
      else
        return self.node_list_false.render(context)
      end
    end

    def self.create(parser, token)
      # get the parts after the block type
      parts = token.contents.split.slice(1..-1)
      var = ExpressionParser.new(parts).parse()
      node_list_true = parser.parse(['else', 'endif'])
      token = parser.next_token()

      if token.contents == 'else'
        node_list_false = parser.parse(['endif'])
        parser.remove_first_token()
      else
        node_list_false = NodeList.new
      end

      IfNode.new(var, node_list_true, node_list_false)
    end

  end

  class ForEachNode < Node

    attr_accessor :var, :enumerable, :node_list

    def initialize(var, enumerable, node_list)
      self.var = var
      self.enumerable = enumerable
      self.node_list = node_list
    end

    #TODO Refactor
    def render(context)
      compiled_string = StringIO.new
      context_enumerable = context.get(InvocationResolver.new(self.enumerable))
      first = 0
      last = context_enumerable.size - 1
      size = context_enumerable.size
      context_enumerable.each_with_index do |obj, i|
        context.push(var.to_sym => obj)

        loop_context = ForLoopContext.new
        loop_context.first = i == first
        loop_context.last = i == last
        loop_context.counter0 = i
        loop_context.counter = i+1
        loop_context.revcounter = size
        loop_context.revcounter0 = size - 1
        size -= 1

        begin
          loop_context.parentloop = context.get(InvocationResolver.new('forloop'))
        rescue NoMethodError
        end

        context.put(:forloop, loop_context)

        compiled_string << node_list.render(context)
        context.pop()
      end

      compiled_string.string
    end

    def self.create(parser, token)
      parts = token.contents.split.slice(1..-1)
      node_list = parser.parse(['endfor'])
      token = parser.next_token()
      var, enumerable = parts[0], parts[2]

      ForEachNode.new(var, enumerable, node_list)
    end

  end
end
