require 'httpclient'
require 'nokogiri'

class CmisClient
    module WebService
        def get(url, query = {})
            @log.debug("GET on #{url}")
            client = HTTPClient.new
            client.set_auth(url, @username, @password)
            content = client.get_content(url, query)
            Nokogiri::XML.parse(content)
        end

        def post(url, body = {})
            client = HTTPClient.new
            client.set_auth(url, @username, @password)
            content = client.post_content(url, body)
            Nokogiri::XML.parse(content)
        end

        def get_content(url, &block)
            client = HTTPClient.new
            client.set_auth(url, @username, @password)
            client.get_content(url, &block)
        end
    end
end
