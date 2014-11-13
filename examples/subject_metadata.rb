#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require 'piggybank'
require 'pp'

keyfile = ARGV[0]
study_id = ARGV[1]
if !keyfile
  puts "Usage: #{__FILE__} <keyfile> <study_id>"
  exit(1)
end

pb = Piggybank.logged_in_from_file keyfile

subjects = pb.list_subjects(study_id)

detailed = pb.get_demographics(subjects.last)
puts pb.agent.page.body
pp detailed

