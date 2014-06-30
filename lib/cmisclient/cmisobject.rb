class CmisClient
    class CmisObject
        include CmisClient::XmlUtils
        attr_reader :xml_doc

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

        def cmis_object_id
            @object_id ||= properties['cmis:objectId']
        end

        def properties
            if @properties.nil?
                @properties = {}
                reload if @xml_doc.nil?
                properties_elem = children_by_tag_ns(@xml_doc, CMIS_NS, 'properties').first
                children = properties_elem.children.select {|e| e.element? && e.namespace.href == CMIS_NS}
                children.each do |node|
                    property_name = node['propertyDefinitionId']
                    property_value = nil
                    value_nodes = children_by_tag_ns(node, CMIS_NS, 'value')
                    if !value_nodes.empty? && !value_nodes.first.children.empty?
                        if value_nodes.length == 1
                            property_value = parse_prop_value(
                                value_nodes.first.children.first.content,
                                node.name)
                        else
                            property_value = value_nodes.map {|n| parse_prop_value(n.children.first.content, node.name)}
                        end
                    end
                    @properties[property_name] = property_value
                end
            end
            @properties
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

        end
    end
end
