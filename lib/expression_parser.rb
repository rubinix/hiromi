module Hiromi

  # Helperer to construct an Operator using infix notation
  def self.infix(bp, fun)
    Hiromi::Operator.new(bp, fun)
  end

  # Template to applying operators to the operrands
  class Operator

    attr_accessor :bp, :fun, :left, :right

    def initialize(bp, fun)
      self.bp = bp
      self.fun = fun
    end

    def lbp
      self.bp
    end

    def led(left, parser)
      self.left = left
      self.right = parser.expression(bp)

      return self
    end

    def eval(context)
      begin
        return fun.call(context, self.left, self.right)
      rescue => e
        # Templates shouldn't throw exceptions when rendering.  We are
        # most likely to get exceptions for things like {% if foo in bar
        # %} where 'bar' does not support 'in', so default to False
        return false
      end
    end

  end

  class LiteralToken

    attr_accessor :value

    def initialize(value)
      self.value = value
    end

    def nud(parser)
      return self
    end

    def lbp
      0
    end

    def eval(context)
      context.get(InvocationResolver.new(self.value))
    end

  end

  class EndToken

    def nud(parser)
      raise "Unexpected end end of expression in if tag"
    end

    def lbp
      0
    end

  end

  class ExpressionParser

    attr_accessor :tokens, :pos, :current_token

    OPERATORS = {
      'or' => Hiromi.infix(6, lambda {|context, x, y| x.eval(context) || y.eval(context)}),
      'and' => Hiromi.infix(7, lambda {|context, x, y| x.eval(context) && y.eval(context)}),
      # 'not': prefix(8, lambda context, x: not x.eval(context)),
      'in' => Hiromi.infix(9, lambda {|context, x, y| y.eval(context).include?(x.eval(context))}),
      'not in' => Hiromi.infix(9, lambda {|context, x, y| !y.eval(context).include?(x.eval(context))}),
      '=' => Hiromi.infix(10, lambda {|context, x, y| x.eval(context) == y.eval(context)}),
      '==' => Hiromi.infix(10, lambda {|context, x, y| x.eval(context) == y.eval(context)}),
      '!=' => Hiromi.infix(10, lambda {|context, x, y| x.eval(context) != y.eval(context)}),
      '>' => Hiromi.infix(10, lambda {|context, x, y| x.eval(context) > y.eval(context)}),
      '>=' => Hiromi.infix(10, lambda {|context, x, y| x.eval(context) >= y.eval(context)}),
      '<' => Hiromi.infix(10, lambda {|context, x, y| x.eval(context) < y.eval(context)}),
      '<=' => Hiromi.infix(10, lambda {|context, x, y| x.eval(context) <= y.eval(context)})
    }

      def initialize(tokens)
        self.tokens = []
        self.pos = 0

        iter = tokens.each

        begin
          while(token = iter.next)
            if token == 'not' && iter.peek() == 'in'
              self.tokens << self.transform_token('not in')
              iter.next()
            else
              self.tokens << self.transform_token(token)
            end

          end
        rescue StopIteration
        end

        self.current_token = self.next()
      end

      def next()
        return EndToken.new if self.pos >= self.tokens.size

        result = self.tokens[self.pos]
        self.pos += 1

        return result
      end

      def transform_token(token)
        if (op = OPERATORS[token])
          return op
        else
          return Hiromi::LiteralToken.new(token)
        end
      end

      def parse()
        result = self.expression()

        unless self.current_token.is_a?(EndToken)
          raise "Unused token at end of if expression."
        end

        result
      end

      def expression(rbp=0)
        token = self.current_token
        self.current_token = self.next()
        left = token.nud(self)
        while rbp < self.current_token.lbp
          token = self.current_token
          self.current_token = self.next()
          left = token.led(left, self)
        end

        return left
      end

  end

end
