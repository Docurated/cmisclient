require 'kconv' if(RUBY_VERSION.start_with? '1.9') # bug in rubyntlm with ruby 1.9.x
require 'logging'
require 'cmisclient/xmlutils'
require 'cmisclient/webservice'
require 'cmisclient/cmisobject'
require 'cmisclient/repository'
require 'cmisclient/folder'
require 'cmisclient/document'
require 'cmisclient/changeentry'

class CmisClient
    include CmisClient::WebService
    include CmisClient::XmlUtils

    attr_reader :url

    def initialize(url, username, password, opts = {})
        @log = Logging.logger[self.class.name.to_s.to_sym]
        @url = url
        @username = username
        @password = password
        @opts = opts
    end

    def default_repository
        doc = get(@url)
        nodes = children_by_tag_ns(doc, APP_NS, 'workspace')
        Repository.new(self, nodes.first)
    end

    def repositories
        doc = get(@url)
        nodes = children_by_tag_ns(doc, APP_NS, 'workspace')
        nodes.map {|n| Repository.new(self, n)}
    end
end
