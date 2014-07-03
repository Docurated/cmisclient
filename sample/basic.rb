#!/usr/bin/env ruby

$:.unshift(File.join('..', 'lib'))
require 'cmisclient'

client = CmisClient.new(
    'http://ec2-50-19-42-42.compute-1.amazonaws.com/_vti_bin/cmis/rest/3970D904-DBF0-429B-84E1-635792DAA112?getrepositoryinfo',
    'AWEC2\\Daniel-Admin',
    'w0rdpa$$')
repo = client.default_repository

doc = repo.root_folder.get_children.each do |doc|
    name = doc.properties['cmis:name']
    puts "found #{name}"
end

token = repo.latest_change_log_token
puts token

old_change_token = '1;3;3970d904-dbf0-429b-84e1-635792daa112;635394141574630000;1742'

changes = repo.get_content_changes({ 'changeLogToken' => old_change_token, 'includeProperties' => 'true' })

changes.each do |change|
    if change.cmis_object_id == '13'
        puts "#{change.change_type}: #{change.id} #{change.change_time} #{change.cmis_object_id}"
        puts change.xml_doc
        document = repo.get_object(change.cmis_object_id, true)
        puts "#{document.paths}: #{document.version_series_id}/#{document.instance_id}"
    end
end
