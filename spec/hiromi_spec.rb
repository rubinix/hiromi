require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Hiromi::Template" do
  it "renders plain text" do
    hiromi = Hiromi.new('Hello, world!')
    hiromi.render.should == 'Hello, world!'
  end

  context "given a context of data" do
    let(:context) do
      Context.new(:target => 'world', :name => 'Allen')
    end

    it "substitutes a string key with it's context value" do
      hiromi = Hiromi.new('Hello, {{ target }}!')
      hiromi.render(context).should == 'Hello, world!'
    end

    it "substitutes a key with an object receiveing a message" do
      TestObject = Struct.new(:name)
      context.put(:target, TestObject.new('world'))
      hiromi = Hiromi.new('Hello, {{ target.name }}!')
      hiromi.render(context).should == 'Hello, world!'
    end

    it "substitutes multiple variable tags" do
      hiromi = Hiromi.new('Hello, {{ target }}, my name is {{ name }}!')
      hiromi.render(context).should == 'Hello, world, my name is Allen!'
    end

    context "when handling if blocks" do
      it "renders the text in the true branch upon evaluating to true" do
        context.put(:is_tall_enough, true)
        hiromi = Hiromi.new('Hello Allen{% if is_tall_enough %}, you are tall.{% endif %}')
        hiromi.render(context).should == 'Hello Allen, you are tall.'
      end

      it "renders the text outside of the true branch upon evaluating to false" do
        context.put(:is_tall_enough, false)
        hiromi = Hiromi.new('Hello Allen{% if is_tall_enough %}, you are tall.{% endif %}')
        hiromi.render(context).should == 'Hello Allen'
      end

      it "renders the text in else branch upon evaluating to false" do
        context.put(:is_tall_enough, false)
        hiromi = Hiromi.new("Hello Allen{% if is_tall_enough %}, you are tall.{% else %}, sorry, you aren't tall enough.{% endif %}")
        hiromi.render(context).should == "Hello Allen, sorry, you aren't tall enough."
      end
    end

    context "when handling for block tags" do
      let :context do
        Context.new(:names => ['Foo', 'Bar'])
      end
      it "renders a block for each item in the collection" do
        hiromi = Hiromi.new("{% for name in names %}Name is: {{ name }}, {% endfor %}")
        hiromi.render(context).should == "Name is: Foo, Name is: Bar, "
      end

      context "that contain magic forloop variables" do
        it "can render a counter" do
          hiromi = Hiromi.new("{% for name in names %}The counter is {{ forloop.counter }}, {% endfor %}")
          hiromi.render(context).should == "The counter is 1, The counter is 2, "
        end

        it "can render a counter0" do
          hiromi = Hiromi.new("{% for name in names %}The counter is {{ forloop.counter0 }}, {% endfor %}")
          hiromi.render(context).should == "The counter is 0, The counter is 1, "
        end

        it "can render a revcounter" do
          hiromi = Hiromi.new("{% for name in names %}The revcounter is {{ forloop.revcounter }}, {% endfor %}")
          hiromi.render(context).should == "The revcounter is 2, The revcounter is 1, "
        end

        it "can render a revcounter0" do
          hiromi = Hiromi.new("{% for name in names %}The revcounter0 is {{ forloop.revcounter0 }}, {% endfor %}")
          hiromi.render(context).should == "The revcounter0 is 1, The revcounter0 is 0, "
        end

        it "can render first" do
          hiromi = Hiromi.new("{% for name in names %}{{ forloop.first }}, {% endfor %}")
          hiromi.render(context).should == "true, false, "
        end

        it "can render last" do
          hiromi = Hiromi.new("{% for name in names %}{{ forloop.last }}, {% endfor %}")
          hiromi.render(context).should == "false, true, "
        end

        it "can render parentloop" do
          context.put(:outside, [1,2,3])
          hiromi = Hiromi.new("{% for val in outside %}{% for name in names %}The parent counter is {{ forloop.parentloop.counter }}, {% endfor %}{% endfor %}")
          hiromi.render(context).should == "The parent counter is 1, The parent counter is 1, The parent counter is 2, The parent counter is 2, The parent counter is 3, The parent counter is 3, "
        end
      end
    end

    context "that contains filter expressions" do
      it "renders the variable downcased with a 'lower' filter" do
        hiromi = Hiromi.new("{{ name|lower }}")
        hiromi.render(context).should == 'allen'
      end

      it "renders the length of a variable with a 'length' filter" do
        hiromi = Hiromi.new("{{ name|length }}")
        hiromi.render(context).should == '5'
      end

      it "renders the result of chained filters" do
        hiromi = Hiromi.new("{{ name|lower|length }}")
        hiromi.render(context).should == '5'
      end
    end

  end
end
