require 'ostruct'
require 'uri'

class CmisClient
    class Repository
        include CmisClient::XmlUtils

        attr_reader :xml_doc

        def initialize(cmis_client, xml_doc)
            @log = Logging.logger[self.class.name.to_s.to_sym]
            @cmis_client = cmis_client
            @xml_doc = xml_doc
        end
        
        def title
            my_children_by_tag_ns(ATOM_NS, 'title').first.content
        end

        def id
            @id ||= my_first_child_content(CMIS_NS, 'repositoryId')
        end

        def name
            @name ||= my_first_child_content(CMIS_NS, 'repositoryName')
        end
        
        def repository_info
            if @repository_info.nil?
                repo_info_elem = my_children_by_tag_ns(CMISRA_NS, 'repositoryInfo')
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
            link_elem = my_children_by_tag_ns(ATOM_NS, 'link').find {|l| l['rel'] == rel}
            link_elem.nil? ? nil : link_elem['href']
        end

        def get_object_doc_xml(object_id, latest = false)
            template = uri_templates['objectbyid'].template
            params = {
                'id' => object_id,
                'filter' => '',
                'includeAllowableActions' => 'false',
                'includePolicyIds' => 'false',
                'includeRelationships' => '',
                'includeACL' => 'false',
                'renditionFilter' => '' }
            by_object_id_url = multiple_replace(template, params)
            query = {}
            query['returnVersion'] = 'latest' if latest
            @cmis_client.get(by_object_id_url, query)
        end

        def get_object_by_instance_id(instance_id)
            get_object(instance_id)
        end

        def get_object_by_version_series_id(version_series_id)
            get_object(version_series_id, true)
        end

        def query(statement)
            template = uri_templates['query'].template

            params = {
                'q' => statement,
                'includeAllowableActions' => 'false',
                'maxItems' => '1000',
                'skipCount' => '0'
            }

            query_url = multiple_replace(template, params)

            @cmis_client.post(query_url)
        end

        private

        def get_object(object_id, latest = false)
            doc_xml = get_object_doc_xml(object_id, latest)
            cmis_object = CmisObject.new(@cmis_client, self, nil, doc_xml)
            # FIXME: repeated code follows
            base_type = cmis_object.properties['cmis:baseTypeId']
            if base_type == 'cmis:document'
                Document.new(@cmis_client, @repo, cmis_object.cmis_object_id, cmis_object.xml_doc)
            end
        end

        def multiple_replace(text, mapping)
            replaced = text
            mapping.each do |placeholder, replacement|
                replaced = replaced.gsub("\{#{placeholder}\}", URI.escape(replacement, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")))
            end
            replaced
        end

        def uri_templates
            if @uri_templates.nil?
                @uri_templates = {}
                uri_template_elems = my_children_by_tag_ns(CMISRA_NS, 'uritemplate')
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
