Gem::Specification.new do |s|
  s.name = 'micromachine'
  s.version = '1.1.0'
  s.summary = %{Minimal Finite State Machine.}
  s.description = %Q{There are many finite state machine implementations for Ruby, and they all provide a nice DSL for declaring events, exceptions, callbacks, and all kinds of niceties in general.\n\nBut if all you want is a finite state machine, look no further: this has less than 50 lines of code and provides everything a finite state machine must have, and nothing more.}
  s.author = "Michel Martens"
  s.email = "michel@soveran.com"
  s.homepage = "http://github.com/soveran/micromachine"
  s.license = "MIT"

  s.files = Dir["lib/**/*.rb", "README*", "LICENSE", "Rakefile", "*.gemspec", "example/**/*.*"]
  s.add_development_dependency 'contest'
end
