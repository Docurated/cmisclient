class CmisClient
    class CmisObject
        include CmisClient::XmlUtils

        def initialize(cmis_client, repo, object_id = nil, xml_doc = nil, opts = {})
            @cmis_client = cmis_client
            @repo = repo
            @object_id = object_id
            @name = nil
            @xml_doc = xml_doc
            @opts = opts
        end

        def reload
            templates = @repo.get_uri_templates
            template = templates['objectbyid'].template
            params = {
                '{id}' => @object_id,
                '{filter}' => '',
                '{includeAllowableActions}' => 'false',
                '{includePolicyIds}' => 'false',
                '{includeRelationships}' => '',
                '{includeACL}' => 'false',
                '{renditionFilter}' => '' }
            by_object_id_url = multiple_replace(template, params)
            @xml_doc = @cmis_client.get(by_object_id_url)
        end

        private

        def multiple_replace(text, mapping)
            replaced = text
            mapping.each do |placeholder, replacement|
                replaced = replaced.gsub(placeholder, replacement)
            end
            replaced
        end

        def get_link(rel, ltype = nil)
            reload if @xml_doc.nil?
            link_elems = children_by_tag_ns(@xml_doc, ATOM_NS, 'link')
            link = link_elems.find do |elem|
                rel_match = rel == elem['rel']
                type_match = ltype.nil? ? true : !ltype.match(elem['type'] || '').nil?
                rel_match && type_match
            end

            link.nil? ? nil : link.attributes['href'].content
        end

        def get_specialized_object(xml_doc)
            puts xml_doc
        end
    end
end
