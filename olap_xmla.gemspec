$:.push File.expand_path("../lib", __FILE__)

require 'olap_xmla/version'

Gem::Specification.new do |spec|
  spec.name          = "olap_xmla"
  spec.version       = OlapXmla::VERSION
  spec.authors       = ["Unact"]
  spec.summary       = %q{OLAP XMLA gem}
  spec.description   = %q{Make MDX queries to OLAP databases using XMLA}
  spec.homepage      = "https://github.com/Unact/olap-xmla"
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.test_files    = Dir["spec/**/*"]

  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "rspec"
  spec.add_runtime_dependency "savon", '~> 2.5.1'
end
