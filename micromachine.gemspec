Gem::Specification.new do |s|
  s.name = 'micromachine'
  s.version = '0.0.2'
  s.summary = %{Minimal Finite State Machine.}
  s.date = %q{2009-03-07}
  s.author = "Michel Martens"
  s.email = "michel@soveran.com"
  s.homepage = "http://github.com/soveran/micromachine"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.files = ["lib/micromachine.rb", "README.rdoc", "LICENSE", "Rakefile", "example/micromachine_sample.rb", "example/micromachine_sample_gem.rb"]

  s.require_paths = ['lib']

  s.extra_rdoc_files = ["README.rdoc"]
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "micromachine", "--main", "README.rdoc"]
end

