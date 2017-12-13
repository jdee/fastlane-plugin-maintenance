require "active_support/core_ext/array"
require "active_support/core_ext/string"
require "pattern_patch"
require "rubygems"
require "set"

module Fastlane
  module Actions
    class UpdateRubocopAction < Action
      class << self
        def run(params)
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

        def available_options
          [
          ]
        end

        def description
          "More to come"
        end

        def latest_rubocop_gemspec
          spec_tuple = Gem::SpecFetcher.fetcher.detect :latest do |name_tuple|
            name_tuple.name == 'rubocop'
          end.first

          name_tuple, source = spec_tuple.first, spec_tuple.second
          source.fetch_spec name_tuple
        end

        def gemspec_path
          Dir[File.expand_path("*.gemspec")].first
        end

        def gemspec
          return @gemspec if @gemspec
          # disable rubocop: Security/Eval
          @gemspec = eval(File.read(gemspec_path))
          # enable rubocop: Security/Eval
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

          UI.message "3. Running rubocop to verify changes. This should pass."
          sh "bundle exec rubocop", print_command_output: false do |status, output, command|
            if status.success?
              UI.success "Done ✅"
              return
            end

            output.split("\n").each do |line|
              UI.important line
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
            UI.important cop
          end

          insertion = "#\n# TODO: Review these failing cops, adjust code and re-enable as necessary.\n#\n\n"
          @failing_cops.each do |c|
            insertion << "#{c}:\n  Enabled: false\n"
          end
          insertion << "\n"

          PatternPatch::Patch.new(
            regexp: /\A/m,
            text: insertion,
            mode: :prepend
          ).apply ".rubocop.yml"
        end
      end
    end
  end
end
