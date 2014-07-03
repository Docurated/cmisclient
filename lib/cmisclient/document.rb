class CmisClient
    class Document < CmisObject
        include XmlUtils

        def self.add_property(name, key, transformation = nil)
            define_method name do
                properties[key]
            end
        end

        add_property :name, 'cmis:name'
        add_property :path, 'cmis:path'
        add_property :created_by, 'cmis:createdBy'
        add_property :created_on, 'cmis:creationDate'
        add_property :last_modified_by, 'cmis:lastModifiedBy'
        add_property :last_modified_on, 'cmis:lastModificationDate'

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

        def paths
            if @paths.nil?
                parent_url = get_link(UP_REL)
                result = @cmis_client.get(
                    parent_url, 
                    {   'filter' => 'cmis:path', 
                        'includeRelativePathSegment' => 'true' })
                entry_elements = children_by_tag_ns(result, ATOM_NS, 'entry')
                @paths = entry_elements.collect do |elem|
                    cmis_object = CmisObject.new(@cmis_client, @repo, nil, elem)
                    path = cmis_object.properties['cmis:path']
                    relative_path_segment = cmis_object.my_children_by_tag_ns(CMISRA_NS, 'relativePathSegment').first.content
                    "#{path}#{path.end_with?('/') ? '' : '/'}#{relative_path_segment}"
                end
            end
            @paths
        end

        def version_series_id
            # a unique id (unique per repo) that stays constant through all versions of this document.
            # see http://docs.oasis-open.org/cmis/CMIS/v1.1/os/CMIS-v1.1-os.html#x1-9000013
            properties['cmis:versionSeriesId']
        end

        def instance_id
            # a unique id (unique per repo) for each version of this doc. See version_series_id for an
            # identifier that is unique across all versions.
            properties['cmis:objectId']
        end

        def path_segment
            my_children_by_tag_ns(CMISRA_NS, 'pathSegment').first.content
        end

        def make_path(folder)
            "#{folder.path}#{folder.path.end_with?('/') ? '' : '/'}#{path_segment}"
        end

        def type; :document; end
    end
end
