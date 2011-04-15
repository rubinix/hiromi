require 'stringio'
require 'token'
require 'nodes'

module Hiromi

  class Parser

    attr_accessor :tokens, :in_extends_state

    def initialize(tokens)
      self.tokens = tokens
      self.in_extends_state = false
    end

    def parse(parse_until=[])
      node_list = NodeList.new

      while (token=self.next_token())
        if token.type == :static && !self.in_extends_state
          node_list << StaticNode.new(token.contents)
        elsif token.type == :variable_tag && !self.in_extends_state
          node_list << VariableNode.new(token.contents)
        elsif token.type == :block_tag
          #Add the token back to the list if we're supposed to exit upon parsing it
          if parse_until.include?(token.contents)
            self.prepend_token(token)
            return node_list
          end
          create_block_node(node_list, token)
        end
      end

      node_list
    end

    def create_block_node(node_list, token)
      block_type = token.contents.split[0]

      if block_type == 'if' && !self.in_extends_state
        node_list << IfNode.create(self, token)
      elsif block_type == 'for' && !self.in_extends_state
        node_list << ForEachNode.create(self, token)
      elsif block_type == 'block'
        override_or_add_to_node_list(node_list, BlockNode.create(self, token))
      elsif block_type == 'extends'
        inherit_node_list!(node_list, token)
      end
    end

    def override_or_add_to_node_list(node_list, block_node)
      if (src_node = node_list.contains(block_node))
        node_list.override_node(src_node, block_node)
      else
        node_list << block_node
      end
    end

    def inherit_node_list!(node_list, token)
      template_name = token.contents.split[1]
      template_name.gsub!("'", "")
      node_list.concat(Hiromi::Template.from_file(template_name).node_list)
      self.in_extends_state = true
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

end
