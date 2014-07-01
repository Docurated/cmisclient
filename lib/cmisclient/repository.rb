require 'ostruct'

class CmisClient
    class Repository
        include CmisClient::XmlUtils

        def initialize(cmis_client, xml_doc)
            @log = Logging.logger[self.class.name.to_s.to_sym]
            @cmis_client = cmis_client
            @xml_doc = xml_doc
        end
        
        def title
            children_by_tag_ns(@xml_doc, ATOM_NS, 'title').first.content
        end
        
        def repository_info
            if @repository_info.nil?
                repo_info_elem = children_by_tag_ns(@xml_doc, CMISRA_NS, 'repositoryInfo')
                info_elems = repo_info_elem.children.select do |n| 
                    n.element? && !['capabilities', 'aclCapability'].include?(n.name)
                end
                @repository_info = Hash[info_elems.collect {|e| [e.name, e.content]}]
            end
            @repository_info
        end

        def latest_change_log_token
            repository_info['latestChangeLogToken']
        end
        
        def root_folder
            root_folder_id = repository_info['rootFolderId']
            Folder.new(@cmis_client, self, root_folder_id)
        end

        def get_uri_templates
            if @uri_templates.nil?
                @uri_templates = {}
                uri_template_elems = children_by_tag_ns(@xml_doc, CMISRA_NS, 'uritemplate')
                uri_template_elems.each do |elem|
                    template, template_type, media_type = nil, nil, nil
                    child_elems = elem.children.select {|e| e.element?}
                    child_elems.each do |ce|
                        template = ce.children.first.content if ce.name == 'template'
                        template_type = ce.children.first.content if ce.name == 'type'
                        media_type = ce.children.first.content if ce.name == 'mediatype'
                    end
                    @uri_templates[template_type] = OpenStruct.new(
                        template: template, 
                        type: template_type,
                        media_type: media_type)
                end
            end
            @uri_templates
        end

        def get_content_changes(query = {})
            # The following query keys are supported:
            #     changeLogToken
            #     includeProperties
            #     includePolicyIDs
            #     includeACL
            #     maxItems
            changes_url = get_link(CHANGE_LOG_REL)
            result = @cmis_client.get(changes_url, query)
            entry_elements = children_by_tag_ns(result, ATOM_NS, 'entry')
            entry_elements.collect {|e| ChangeEntry.new(@cmis_client, @repo, nil, e)}
        end

        def get_link(rel)
            link_elem = children_by_tag_ns(@xml_doc, ATOM_NS, 'link').find {|l| l['rel'] == rel}
            link_elem.nil? ? nil : link_elem['href']
        end
    end
end
