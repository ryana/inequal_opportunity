# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{inequal_opportunity}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Angilly"]
  s.date = %q{2009-04-16}
  s.description = %q{Adds mergable, stackable inequality statements to ActiveRecord conditions}
  s.email = %q{ryan@angilly.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "Rakefile",
    "lib/inequal_opportunity.rb",
    "test/database.example.yml",
    "test/inequal_opportunity_test.rb",
    "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ryana/inequal_opportunity}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Adds mergable, stackable inequality statements to ActiveRecord conditions}
  s.test_files = [
    "test/inequal_opportunity_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
