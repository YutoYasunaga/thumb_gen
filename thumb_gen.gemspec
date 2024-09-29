# frozen_string_literal: true

require_relative 'lib/thumb_gen/version'

Gem::Specification.new do |spec|
  spec.name = 'thumb_gen'
  spec.version = ThumbGen::VERSION
  spec.authors = ['YutoYasunaga']
  spec.email = ['yuto.yasunaga@gmail.com']

  spec.summary = 'Auto generate customized thumbnails for articles.'
  spec.description = 'ThumbGen is a Ruby gem that simplifies the creation of article thumbnails ' \
                     'by allowing developers to easily generate and customize thumbnails with text overlays. ' \
                     'Ideal for blogs, news sites, and any content-driven platforms.'
  spec.homepage = 'https://github.com/YutoYasunaga/thumb_gen'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/YutoYasunaga/thumb_gen.git'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rmagick', '~> 6.0.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
