# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.1.0'
  s.name        = 'adamantite'
  s.version     = '0.0.9'
  s.summary     = 'Yet another password manager.'
  s.description = 'A local password manager written in Ruby.'
  s.authors     = ['Jake Bruemmer']
  s.email       = 'jakebruemmer@gmail.com'
  s.files       = Dir.glob('lib/**/*')
  s.executables << 'adamantite'
  s.homepage    = 'https://jakebruemmer.github.io/adamantite-info/'
  s.license     = 'MIT'
  s.add_runtime_dependency 'glimmer-dsl-libui', '0.11.5'
  s.add_runtime_dependency 'httparty', '0.21.0'
  s.post_install_message = <<-TEXT
    Thank you for installing Adamantite. Please visit the project's
    homepage https://jakebruemmer.github.io/adamantite-info/ if you
    run into any issues when installing or running the gem.
  TEXT
end
