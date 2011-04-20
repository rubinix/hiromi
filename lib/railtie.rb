require 'hiromi'
require 'rails'

module Hiromi

  #TODO Extract this into a separate gem: hiromi-rails
  class TemplateHandler < ActionView::Template::Handler
    include ActionView::Template::Handlers::Compilable

    def compile(template)
      <<-HIROMI
        hiromi = Hiromi::Template.new(%{#{template.source}})
        variables = controller.instance_variable_names

        hash = {}
        variables.each do |name|
          hash[name[1..-1].to_sym] = controller.instance_variable_get(name)
        end

        hiromi_context = Hiromi::Context.new(hash)
        hiromi.render(hiromi_context)
      HIROMI
    end

  end

  class Railtie < Rails::Railtie
    initializer "hiromi.initialize" do |app|
      ActionView::Template.register_template_handler(:hiromi, Hiromi::TemplateHandler)
      Hiromi::Configuration::Templates.home = File.join(app.root.to_s, 'app', 'views')
    end
  end

end
