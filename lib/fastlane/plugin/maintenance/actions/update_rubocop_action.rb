require "fastlane/action"

require "active_support/core_ext/array"
require "active_support/core_ext/string"
require "pattern_patch"
require "rubygems"
require "set"
require "yaml"

module Fastlane
  module Actions
    class UpdateRubocopAction < Action
      class << self
        def run(params)
          unless Gem::Version.new(Fastlane::VERSION) >= Gem::Version.new("2.69.0")
            UI.important "This action requires fastlane >= 2.69.0."
            return false
          end

          spec = latest_rubocop_gemspec
          UI.message "Latest: #{spec.name} #{spec.version}"
          requirement = rubocop_requirement_from_repo
          UI.message "requirement from gemspec: #{requirement}"
          unless requirement.satisfied_by? spec.version
            UI.important "updating gemspec requirement to #{spec.version}"
            update_rubocop_requirement spec.version
          end

          sh "bundle update --quiet rubocop"

          run_rubocop
        end

        def description
          "Updates rubocop to the latest version. Pins your gemspec to a new version of rubocop if " \
          "necessary. Runs rubocop -a to auto-correct many offenses. Adjusts TargetRubyVersion. " \
          "Automatically corrects namespace changes. Disables any remaining failing Cops in your " \
          ".rubocop.yml with a TODO note. Run from the command line with no arguments."
        end

        def authors
          ["Jimmy Dee"]
        end

        def example_code
          [
            "bundle exec fastlane run update_rubocop"
          ]
        end

        def latest_rubocop_gemspec
          spec_tuple = Gem::SpecFetcher.fetcher.detect :latest do |name_tuple|
            name_tuple.name == 'rubocop'
          end.first

          name_tuple = spec_tuple.first
          source = spec_tuple.second
          source.fetch_spec name_tuple
        end

        def gemspec_path
          Dir[File.expand_path("*.gemspec")].first
        end

        def gemspec
          return @gemspec if @gemspec
          # rubocop: disable Security/Eval
          @gemspec = eval(File.read(gemspec_path))
          # rubocop: enable Security/Eval
          @gemspec
        end

        def rubocop_dependency
          gemspec.development_dependencies.find { |d| d.name == "rubocop" }
        end

        def rubocop_requirement_from_repo
          rubocop_dependency.requirement
        end

        def update_rubocop_requirement(version)
          PatternPatch::Patch.new(
            regexp: /(\.add_development_dependency.*rubocop['")\]}]).*$/,
            text: %(\\1, '#{version}'),
            mode: :replace
          ).apply gemspec_path
        end

        def run_rubocop
          adjust_target_ruby_version

          UI.message "1. Running rubocop --auto-correct. This may fail."
          sh "bundle exec rubocop --auto-correct", print_command_output: false do |status|
            if status.success?
              UI.success "Done ✅"
              return
            end
          end

          UI.message "2. Running rubocop --display-cop-names for further automated fixes. This may fail."
          sh "bundle exec rubocop --display-cop-names", print_command_output: false do |status, output, command|
            if status.success?
              UI.success "Done ✅"
              return
            end

            UI.message "Adjusting changed namespaces and disabling failing cops."

            output.split("\n").each do |line|
              case line
              when /has the wrong namespace/
                adjust_namespace line
              else
                add_failing_cop line
              end
            end

            disable_failing_cops
          end

          UI.message "3. Running rubocop --auto-correct to verify changes. This should pass."
          sh "bundle exec rubocop --auto-correct", print_command_output: false do |status, output, command|
            if status.success?
              UI.success "Done ✅"
              return
            end

            UI.important "rubocop still detects offenses. These have to be fixed manually."
            output.split("\n").each do |line|
              UI.message line
            end
          end

          false
        end

        def adjust_namespace(line)
          matches = %r{^(.*): (\w+)/(\w+) has the wrong namespace - should be (\w+)}.match line
          UI.user_error! "Failed to scan #{line.inspect}" unless matches

          path, old_namespace, cop, new_namespace = *matches[1..4]

          UI.important "#{path}: #{old_namespace}/#{cop} -> #{new_namespace}/#{cop}"

          PatternPatch::Patch.new(
            regexp: %r{#{old_namespace}/#{cop}},
            text: "#{new_namespace}/#{cop}",
            mode: :replace,
            global: true
          ).apply path

          true
        end

        def add_failing_cop(line)
          matches = %r{^.+: [A-Z]: (\w+/\w+):}.match line
          return unless matches

          @failing_cops ||= Set.new
          @failing_cops << matches[1]
        end

        def disable_failing_cops
          return unless @failing_cops

          UI.message ""
          UI.important "Temporarily disabling the following cops in .rubocop.yml"
          @failing_cops.each do |cop|
            UI.important " #{cop}"
          end

          insertion = "# --- update_rubocop ---\n"
          insertion << "# TODO: Review these failing cops, adjust code and re-enable as necessary.\n\n"
          insertion << @failing_cops.map { |c| "#{c}:\n  Enabled: false\n" }.join("\n")
          insertion << "# --- update_rubocop ---\n\n"

          PatternPatch::Patch.new(
            regexp: /\A/,
            text: insertion,
            mode: :prepend
          ).apply ".rubocop.yml"
        end

        def adjust_target_ruby_version
          rubocop_config = YAML.load_file ".rubocop.yml"
          versions = rubocop_config.map { |k, v| v['TargetRubyVersion'] }.compact.map(&:to_f).uniq
          return unless versions.any? { |v| v < 2.1 }

          version = [versions.max, 2.1].max

          UI.important "Updating TargetRubyVersion to #{version}"

          PatternPatch::Patch.new(
            regexp: /(TargetRubyVersion\s*:\s*)\d\.\d(.*)$/,
            text: "\\1#{version}\\2",
            mode: :replace,
            global: true
          ).apply ".rubocop.yml"
        end
      end
    end
  end
end
