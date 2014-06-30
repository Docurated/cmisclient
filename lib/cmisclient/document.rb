class CmisClient
    class Document < CmisObject
        include XmlUtils

        def get_content(&block)
            # Sharepoint seems to always return content back with a Content-Transfer-Encoding of base64.
            # Unfortunately I can't determine how to use the httpclient library to get the header back
            # while still accessing content as a stream, so for now I'm assuming it's always returning
            # base64.
            content_elem = children_by_tag_ns(@xml_doc, ATOM_NS, 'content').first
            url = content_elem['src']

            buffer = ''
            @cmis_client.get_content(url) do |chunk|
                buffer += chunk
                leftover = buffer.length % 4
                to_convert = buffer[0, buffer.length - leftover]
                buffer = buffer[buffer.length - leftover, leftover]
                block.call(Base64.strict_decode64(to_convert))
            end
        end
    end
end
