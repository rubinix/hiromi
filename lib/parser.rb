require 'stringio'

class Parser

  attr_accessor :tokens

  def initialize(tokens)
    self.tokens = tokens
  end

  def parse(parse_until=[])
    node_list = NodeList.new

    while (token=self.next_token())
      if token[0] == :static
        node_list << StaticNode.new(token[1])
      elsif token[0] == :variable_tag
        node_list << VariableNode.new(token[1])
      elsif token[0] == :block_tag
        #Add the token back to the list if we're supposed to exit upon parsing it
        if parse_until.include?(token[1])
            self.prepend_token(token)
            return node_list
        end
        node_list << create_block_node(token)
      end
    end

    node_list
  end

  def create_block_node(token)
    block_type = token[1].split[0]

    if block_type == 'if'
      return IfNode.create(self, token)
    end

  end

  def next_token()
    self.tokens.shift()
  end

  def remove_first_token()
    self.tokens.shift()
  end

  def prepend_token(token)
    self.tokens.unshift(token)
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

class IfNode < Node

  attr_accessor :node_list_true, :node_list_false, :var

  def initialize(var, node_list_true, node_list_false=nil)
    self.var = var
    self.node_list_true = node_list_true
    self.node_list_false = node_list_false
  end

  def render(context)
    # if self.var.eval(context)
    if context[var.to_sym] == true
      return self.node_list_true.render(context)
    else
      return self.node_list_false.render(context)
    end
  end

  def self.create(parser, token)
    # get the parts after the block type
    parts = token[1].split.slice(1..-1)
    node_list_true = parser.parse(['else', 'endif'])
    token = parser.next_token()
    var = parts.first

    if token[1] == 'else'
      node_list_false = parser.parse(['endif'])
      parser.remove_first_token()
    else
      node_list_false = NodeList.new
    end

    IfNode.new(var, node_list_true, node_list_false)
  end

end
