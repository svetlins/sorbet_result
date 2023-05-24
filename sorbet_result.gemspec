# frozen_string_literal: true

require_relative "lib/sorbet_result/version"

Gem::Specification.new do |spec|
  spec.name = "sorbet_result"
  spec.version = SorbetResult::VERSION
  spec.authors = ["Svetlin Simonyan"]
  spec.email = ["svetlin.s@gmail.com"]

  spec.summary = "A strongly typed Result class for use with Sorbet"
  spec.description = "A strongly typed Result class for use with Sorbet"
  spec.homepage = "https://github.com/svetlins/sorbet_result"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = "https://github.com/svetlins/sorbet_result"
  spec.metadata["source_code_uri"] = "https://github.com/svetlins/sorbet_result"
  spec.metadata["changelog_uri"] = "https://github.com/svetlins/sorbet_result"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "sorbet-static-and-runtime", "~> 0.5.10841"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
