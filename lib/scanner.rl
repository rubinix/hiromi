class Scanner

%%{

  machine scanner;

  variable_tag = '{{.*?}}';
  plain_text = any+;

  main := |*

    plain_text {
      create_token(:variable_tag, data, tokens, ts, te)
    };

    variable_tag { 
      create_token(:variable_tag, data, tokens, ts, te)
    };

  *|;

}%%

  def tokenize(data)
    data = data.unpack("c*") if(data.is_a?(String))
    eof = data.length
    scanner_start = 0
    tokens = []

    %% write init;
    %% write exec;

  end

  def create_token(name, data, tokens, ts, te)
    tokens << {:type => name, :value => data[ts...te].pack("c*") }
  end

end
