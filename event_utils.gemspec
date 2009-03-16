# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{event_utils}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paolo Negri"]
  s.date = %q{2009-03-12}
  s.email = %q{hungryblank@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["README.rdoc", "lib/event_utils", "lib/event_utils/evented_loop.rb", "lib/event_utils.rb", "test/deferred_loop_test.rb", "test/test_helper.rb", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/hungryblank/event_utils}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{provides various facilities to help building tools on top of eventmachine}
  s.add_dependency('eventmachine')

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
