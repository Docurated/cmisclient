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
            repo_info_elem = children_by_tag_ns(@xml_doc, CMISRA_NS, 'repositoryInfo')
            info_elems = repo_info_elem.children.select do |n| 
                n.element? && !['capabilities', 'aclCapability'].include?(n.name)
            end
            Hash[info_elems.collect {|e| [e.name, e.content]}]
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
    end
end
