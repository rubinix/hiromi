require 'stringio'

class Parser

  def parse(tokens)
    node_list = NodeList.new

    tokens.each do |token|
      if token[0] == :static
        node_list << StaticNode.new(token[1])
      elsif token[0] == :variable_tag
        node_list << VariableNode.new(token[1][2...-2].strip)
      end
    end

    node_list
  end

end

class NodeList

  def initialize
    @nodes = []
  end

  def <<(node)
    @nodes << node
  end

  def render(context)
    compiled_string = StringIO.new
    @nodes.each do |node|
      compiled_string << node.render(context)
    end
    compiled_string.string
  end

end

class Node

  attr_accessor :token

  def initialize(token)
    self.token = token
  end

end

class StaticNode < Node

  def render(context)
    self.token
  end

end

class VariableNode < Node

  def render(context)
    context[token.to_sym]
  end

end
