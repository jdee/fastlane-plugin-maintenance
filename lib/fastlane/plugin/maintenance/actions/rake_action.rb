require "fastlane/action"
require "rake"

module Fastlane
  module Actions
    class RakeAction < Action
      class << self
        include Rake::DSL

        def run(params)
          if File.exist?(params[:rakefile])
            # Can't require. Because no .rb?
            # rubocop: disable Security/Eval
            eval File.read(params[:rakefile])
            # rubocop: enable Security/Eval
          end

          Rake::Task[params[:task]].invoke
        end

        def available_options
          [
            FastlaneCore::ConfigItem.new(
              key: :task,
              description: "Rake task to build",
              is_string: false
            ),
            FastlaneCore::ConfigItem.new(
              key: :rakefile,
              description: "Rakefile to use",
              type: String,
              optional: true,
              default_value: "Rakefile"
            )
          ]
        end

        def description
          "Release your plugin to RubyGems using rake release."
        end

        def authors
          ["Jimmy Dee"]
        end

        def example_code
          [
            "bundle exec fastlane run release_plugin"
          ]
        end
      end
    end
  end
end
