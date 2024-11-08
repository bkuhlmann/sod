# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "sod"
  spec.version = "0.18.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/sod"
  spec.summary = "A domain specific language for creating composable command line interfaces."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/sod/issues",
    "changelog_uri" => "https://alchemists.io/projects/sod/versions",
    "homepage_uri" => "https://alchemists.io/projects/sod",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Sod",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/sod"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = ">= 3.3", "<= 3.4"
  spec.add_dependency "cogger", "~> 0.30"
  spec.add_dependency "containable", "~> 0.2"
  spec.add_dependency "infusible", "~> 3.11"
  spec.add_dependency "optparse", "~> 0.6"
  spec.add_dependency "refinements", "~> 12.10"
  spec.add_dependency "tone", "~> 1.0"
  spec.add_dependency "zeitwerk", "~> 2.7"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
