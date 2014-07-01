class CmisClient
    class ChangeEntry < CmisObject
        def id
            # Unique ID of the change entry.
            @change_entry_id ||= children_by_tag_ns(@xml_doc, ATOM_NS, 'id').first.children.first.content
        end

        def change_type
            # Should be one of:
            #  - :created
            #  - :updated
            #  - :deleted
            #  - :security
            @change_type ||= children_by_tag_ns(@xml_doc, CMIS_NS, 'changeType').first.children.first.content.to_sym
        end

        def change_time
            @change_time ||= DateTime.iso8601(children_by_tag_ns(@xml_doc, CMIS_NS, 'changeTime').first.children.first.content)
        end
    end
end
