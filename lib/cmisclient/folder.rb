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
            
        end
    end
end
