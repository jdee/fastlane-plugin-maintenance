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

          case params[:options]
          when Array
            # Can pass multiple options as an array
            args = *params[:options]
          else
            args = params[:options]
          end

          UI.header "rake #{params[:task]}"
          Rake::Task[params[:task]].invoke args
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
              default_value: "Rakefile",
              verify_block: ->(path) { File.open(path); true }
            ),
            FastlaneCore::ConfigItem.new(
              key: :options,
              description: "Options for task",
              is_string: false,
              optional: true
            )
          ]
        end

        def description
          "General-purpose rake action to invoke tasks from a Rakefile or elsewhere."
        end

        def authors
          ["Jimmy Dee"]
        end

        def example_code
          [
            "rake task: :release",
            "rake task: :default",
            %(rake task: :default, rakefile: "Rakefile")
          ]
        end
      end
    end
  end
end
