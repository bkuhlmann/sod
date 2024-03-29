# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "sod"
  spec.version = "0.7.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/sod"
  spec.summary = "A domain specific language for creating composable command line interfaces."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/sod/issues",
    "changelog_uri" => "https://alchemists.io/projects/sod/versions",
    "documentation_uri" => "https://alchemists.io/projects/sod",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Sod",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/sod"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.3"
  spec.add_dependency "cogger", "~> 0.16"
  spec.add_dependency "dry-container", "~> 0.11"
  spec.add_dependency "infusible", "~> 3.4"
  spec.add_dependency "refinements", "~> 12.1"
  spec.add_dependency "tone", "~> 1.0"
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
