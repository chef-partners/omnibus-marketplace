module Biscotti
  module Extensions
    module SetupDSL
      module_function

      module Helpers
        def starter_kit
          Biscotti::StarterKit.new(credentials: Biscotti::App.settings.biscotti["credentials"], params: params)
        end
      end

      def registered(app)
        app.helpers Helpers
      end
    end
  end
end
