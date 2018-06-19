Gem::Specification.new do |s|
  s.name      = "reckoner"
  s.platform  = Gem::Platform::RUBY
  s.license   = "Apache-2.0"
  s.homepage  = "https://github.com/chef-partners/omnibus-marketplace/tree/master/files/reckoner"
  s.authors   = "Chef Software Inc."
  s.email     = "partnereng@chef.io"
  s.summary   = "AWS Helper Application"
  s.version   = '1.0.0'

  s.required_ruby_version = ">= 2.4"

  s.add_dependency "activesupport",     "~> 5.2"
  s.add_dependency "aws-sdk",           "~> 2"
  s.add_dependency "chef",              "~> 13"
  s.add_dependency "chef-marketplace",  "~> 0"
  s.add_dependency "clockwork",         "~> 2.0"
  s.add_dependency "elasticsearch",     "~> 5.0"
  s.add_dependency "pg",                "~> 0", "< 1"

  s.add_development_dependency "chefstyle",   '~> 0.10'

  s.metadata['allowed_push_host'] = 'https://artifactory.chef.co'

  s.bindir = "bin"
  s.executables = %w(reckoner)

  s.files = %w(Gemfile LICENSE) + Dir.glob("*.gemspec") + Dir.glob("{lib,spec}/**/*")
end
