require 'rubygems'
Gem::Specification.new do |s|
    s.name = 'cmisclient'
    s.version = '0.1.0'
    s.date = '2014-07-03'
    s.author = 'Docurated'
    s.email = 'adam@docurated.com'
    s.homepage = 'http://github.com/docurated/cmisclient'
    s.files = Dir.glob('{lib,sample}/**/*') + ['README.md']
    s.require_path = 'lib'
    s.license = 'ruby'
    s.summary = 'Simple CMIS client for Ruby. Only supports a subset of CMIS right now.'
    s.description = 'Simple CMIS client for Ruby. Only supports a subset of CMIS right now.'
    s.add_dependency 'httpclient', '>= 2.4.0'
    s.add_dependency 'rubyntlm', '~> 0.4.0'
end
