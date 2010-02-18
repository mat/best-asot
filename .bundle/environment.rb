# DO NOT MODIFY THIS FILE

require 'digest/sha1'
require "rubygems"

module Bundler
  module SharedHelpers

    def reverse_rubygems_kernel_mixin
      # Disable rubygems' gem activation system
      ::Kernel.class_eval do
        if private_method_defined?(:gem_original_require)
          alias rubygems_require require
          alias require gem_original_require
        end

        undef gem
      end
    end

    def default_gemfile
      gemfile = find_gemfile
      gemfile or raise GemfileNotFound, "The default Gemfile was not found"
      Pathname.new(gemfile)
    end

    def in_bundle?
      find_gemfile
    end

  private

    def find_gemfile
      return ENV['BUNDLE_GEMFILE'] if ENV['BUNDLE_GEMFILE']

      previous = nil
      current  = File.expand_path(Dir.pwd)

      until !File.directory?(current) || current == previous
        filename = File.join(current, 'Gemfile')
        return filename if File.file?(filename)
        current, previous = File.expand_path("#{current}/.."), current
      end
    end

    def clean_load_path
      # handle 1.9 where system gems are always on the load path
      if defined?(::Gem)
        me = File.expand_path("../../", __FILE__)
        $LOAD_PATH.reject! do |p|
          next if File.expand_path(p).include?(me)
          p != File.dirname(__FILE__) &&
            Gem.path.any? { |gp| p.include?(gp) }
        end
        $LOAD_PATH.uniq!
      end
    end

    extend self
  end
end

module Bundler
  LOCKED_BY    = '0.9.5'
  FINGERPRINT  = "d9b2ae6804816a542d78fe4fe622a20f0b87f895"
  SPECS        = [
        {:load_paths=>["/Library/Ruby/Gems/1.8/gems/hpricot-0.8.1/lib"], :version=>"0.8.1", :name=>"hpricot", :groups=>[:default]},
        {:load_paths=>["/Library/Ruby/Gems/1.8/gems/activesupport-2.3.4/lib"], :version=>"2.3.4", :name=>"activesupport", :groups=>[:default]},
        {:load_paths=>["/Library/Ruby/Gems/1.8/gems/rack-1.0.1/lib"], :version=>"1.0.1", :name=>"rack", :groups=>[:default, :test]},
        {:load_paths=>["/Library/Ruby/Gems/1.8/gems/rack-test-0.5.3/lib"], :version=>"0.5.3", :name=>"rack-test", :groups=>[:test]},
        {:load_paths=>["/Library/Ruby/Gems/1.8/gems/sinatra-0.9.4/lib"], :version=>"0.9.4", :name=>"sinatra", :groups=>[:default]},
        {:load_paths=>["/Library/Ruby/Gems/1.8/gems/scruffy-0.2.6/lib"], :version=>"0.2.6", :name=>"scruffy", :groups=>[:default]},
        {:load_paths=>["/Library/Ruby/Gems/1.8/gems/activerecord-2.3.4/lib"], :version=>"2.3.4", :name=>"activerecord", :groups=>[:default]},
      ]
  AUTOREQUIRES = {:test=>[["rack-test", false]], :default=>[["sinatra", false], ["hpricot", false], ["activerecord", false], ["scruffy", false]]}

  extend SharedHelpers

  def self.cripple_ruby_gems
    reverse_rubygems_kernel_mixin
    patch_rubygems
  end

  def self.match_fingerprint
    print = Digest::SHA1.hexdigest(File.read(File.expand_path('../../Gemfile', __FILE__)))
    unless print == FINGERPRINT
      abort 'Gemfile changed since you last locked. Please `bundle lock` to relock.'
    end
  end

  def self.setup(*groups)
    match_fingerprint
    SPECS.each do |spec|
      spec[:load_paths].each { |path| $LOAD_PATH.unshift path }
    end
  end

  def self.require(*groups)
    groups = [:default] if groups.empty?
    groups.each do |group|
      (AUTOREQUIRES[group] || []).each do |file, explicit|
        if explicit
          Kernel.require file
        else
          begin
            Kernel.require file
          rescue LoadError
          end
        end
      end
    end
  end

  def self.patch_rubygems
    specs = SPECS

    ::Kernel.send(:define_method, :gem) do |dep, *reqs|
      opts = reqs.last.is_a?(Hash) ? reqs.pop : {}

      dep  = dep.name if dep.respond_to?(:name)
      unless specs.any?  { |s| s[:name] == dep }
        e = Gem::LoadError.new "#{dep} is not part of the bundle. Add it to Gemfile."
        e.name = dep
        e.version_requirement = reqs
        raise e
      end

      true
    end
  end

  # Setup bundle when it's required.
  cripple_ruby_gems
  setup
end
