require 'stringio'
require 'token'

class Parser

  attr_accessor :tokens

  def initialize(tokens)
    self.tokens = tokens
  end

  def parse(parse_until=[])
    node_list = NodeList.new

    while (token=self.next_token())
      if token.type == :static
        node_list << StaticNode.new(token.contents)
      elsif token.type == :variable_tag
        node_list << VariableNode.new(token.contents)
      elsif token.type == :block_tag
        #Add the token back to the list if we're supposed to exit upon parsing it
        if parse_until.include?(token.contents)
            self.prepend_token(token)
            return node_list
        end
        node_list << create_block_node(token)
      end
    end

    node_list
  end

  def create_block_node(token)
    block_type = token.contents.split[0]

    if block_type == 'if'
      return IfNode.create(self, token)
    elsif block_type == 'for'
      return ForEachNode.create(self, token)
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

class VariableNode < Node

  def render(context)
    context.instance_eval(contents)
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
    if context.instance_eval(var) == true
      return self.node_list_true.render(context)
    else
      return self.node_list_false.render(context)
    end
  end

  def self.create(parser, token)
    # get the parts after the block type
    parts = token.contents.split.slice(1..-1)
    node_list_true = parser.parse(['else', 'endif'])
    token = parser.next_token()
    var = parts.first

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

  def render(context)
    compiled_string = StringIO.new
    context.send(self.enumerable.to_sym).each do |obj|
      c = Context.new(var.to_sym => obj)
      compiled_string << node_list.render(c)
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
