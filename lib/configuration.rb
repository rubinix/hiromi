module Hiromi
  module Configuration

    class Templates
      @home = ''

      class << self
        attr_accessor :home
      end

    end

  end
end

