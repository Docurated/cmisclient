class CmisClient
    module XmlUtils
        ATOM_NS = 'http://www.w3.org/2005/Atom'
        APP_NS = 'http://www.w3.org/2007/app'
        CMISRA_NS = 'http://docs.oasis-open.org/ns/cmis/restatom/200908/'
        CMIS_NS = 'http://docs.oasis-open.org/ns/cmis/core/200908/'

        # standard rels
        DOWN_REL = 'down'
        FIRST_REL = 'first'
        LAST_REL = 'last'
        NEXT_REL = 'next'
        PREV_REL = 'prev'
        SELF_REL = 'self'
        UP_REL = 'up'

        # content types
        ATOM_XML_TYPE = 'application/atom+xml'
        ATOM_XML_ENTRY_TYPE = 'application/atom+xml;type=entry'
        ATOM_XML_ENTRY_TYPE_P = /^application\/atom\+xml.*type.*entry/
        ATOM_XML_FEED_TYPE = 'application/atom+xml;type=feed'
        ATOM_XML_FEED_TYPE_P = /^application\/atom\+xml.*type.*feed/
        CMIS_TREE_TYPE = 'application/cmistree+xml'
        CMIS_TREE_TYPE_P = /^application\/cmistree\+xml/
        CMIS_QUERY_TYPE = 'application/cmisquery+xml'
        CMIS_ACL_TYPE = 'application/cmisacl+xml'

        def children_by_tag_ns(node, ns, tag)
            node.xpath("//ns:#{tag}", { 'ns' => ns })
        end
    end
end
