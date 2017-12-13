module Fastlane
  module Helper
    class MaintenanceHelper
      # class methods that you define here become available in your action
      # as `Helper::MaintenanceHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the maintenance plugin helper!")
      end
    end
  end
end
