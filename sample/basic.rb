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
    puts "downloading #{name}"
    File.open("/home/adam/src/winnative/#{name}", 'wb') do |file|
        doc.get_content do |chunk|
            file.write(chunk)
        end
    end
end




