require 'httpclient'
require 'nokogiri'

class CmisClient
    module WebService
        def get(url, opts = {})
            @log.debug("GET on #{url}")
            client = HTTPClient.new
            client.set_auth(url, @username, @password)
            content = client.get_content(url)
            Nokogiri::XML.parse(content)
        end

        def get_content(url, &block)
            client = HTTPClient.new
            client.set_auth(url, @username, @password)
            client.get_content(url, &block)
        end
    end
end
