# This is just so that the source file can be loaded.
module ::Motion; module Project; class Config
  def self.variable(*); end
end; end; end

require 'date'
$:.unshift File.expand_path('../lib', __FILE__)
require 'motion/project/version'

Gem::Specification.new do |spec|
  spec.name        = 'motion-maven'
  spec.version     = Motion::Project::Maven::VERSION
  spec.date        = Date.today
  spec.summary     = 'Maven integration for RubyMotion projects'
  spec.description = "motion-maven allows RubyMotion projects to have access to the Maven dependency manager."
  spec.author      = 'Joffrey Jaffeux'
  spec.email       = 'j.jaffeux@gmail.com'
  spec.homepage    = 'http://www.rubymotion.com'
  spec.license     = 'MIT'
  spec.files       = Dir.glob('lib/**/*.rb') << 'README.md' << 'LICENSE'
end
