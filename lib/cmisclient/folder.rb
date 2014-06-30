class CmisClient
    class Folder < CmisObject
        include XmlUtils

        def get_children_link
            get_link(DOWN_REL, ATOM_XML_FEED_TYPE_P)
        end

        def get_children
            children_url = get_children_link
            result = @cmis_client.get(children_url)
            entry_elements = children_by_tag_ns(result, ATOM_NS, 'entry')
            entry_elements.collect do |elem|
                cmis_object = CmisObject.new(@cmis_client, @repo, nil, elem)
                base_type = cmis_object.properties['cmis:baseTypeId']
                if base_type == 'cmis:folder'
                    Folder.new(@cmis_client, @repo, cmis_object.cmis_object_id, cmis_object.xml_doc)
                elsif base_type == 'cmis:document'
                    Document.new(@cmis_client, @repo, cmis_object.cmis_object_id, cmis_object.xml_doc)
                end
            end.flatten
        end
    end
end
