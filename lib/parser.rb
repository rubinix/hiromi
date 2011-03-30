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
            return nodelist
        end

        node_list << create_block_node(token)
      end
    end

    node_list
  end

  def create_block_node(token)
    type = token.split[0]
  end

  def next_token()
    self.tokens.shift()
  end

  def remove_first_token()
    self.toeksn.shift()
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

  attr_accessor :nodelist_true, :nodelist_false, :var

  def initialize(var, nodelist_true, nodelist_false=nil)
    self.nodelist_true = nodelist_true
    self.nodelist_false = nodelist_false
  end

  def render(context)
    if self.var.eval(context)
      return self.nodelist_true.render(context)
    else
      return self.nodelist_false.render(context)
    end
  end

  def fun(parser, token)
    # get the parts after the block type
    parts = token.split.slice(1..-1)
    nodelist_true = parser.parse(['else', 'endif'])
    token = parser.next_token()

    if token.contents == 'else'
      nodelist_false = parser.parse(['endif'])
      parser.remove_first_token()
    else
      nodelist_false = NodeList.new
    end

    IfNode.new(..., nodelist_true, nodelist_false)
  end

end
