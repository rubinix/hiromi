require 'strscan'

class Scanner

  def tokenize(data)
    @scanner = StringScanner.new(data)
    tokens = []

    in_tag =  ['{{', '{%'].include?(@scanner.peek(2))

    until @scanner.eos?
      if in_tag
        tokens << scan_tag()
      else
        static_token = scan_text()
        tokens << static_token unless static_token.contents.empty?
      end
      in_tag = !in_tag
    end

    tokens
  end

  def scan_tag()
    text = @scanner.scan_until(/{{.*?}}|{%.*?%}/)

    if text.nil?
      # TODO This means we have a syntax error, no ctag
      # Mark as done.
      @scanner.terminate
      raise Exception
    end

    if text.start_with?('{{')
      text = text[2...-2].strip
      return Token.new(:variable_tag, text)
    elsif text.start_with?('{%')
      text = text[2...-2].strip
      return Token.new(:block_tag, text)
    end
  end

  def scan_text()
    text = scan_until_exclusive(/{{.*?}}|{%.*?%}/)

    if text.nil?
      # Couldn't find any otag, which means the rest is just static text.
      text = @scanner.rest
      # Mark as done.
      @scanner.terminate
    end

    Token.new(:static, text)
  end

  # Scans the string until the pattern is matched. Returns the substring
  # *excluding* the end of the match, advancing the scan pointer to that
  # location. If there is no match, nil is returned.
  def scan_until_exclusive(regexp)
    pos = @scanner.pos
    if @scanner.scan_until(regexp)
      @scanner.pos -= @scanner.matched.size
      @scanner.pre_match[pos..-1]
    end
  end

end
