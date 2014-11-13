#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require 'piggybank'
require 'pp'

keyfile = ARGV[0]
study_id = ARGV[1]
if !keyfile
  puts "Usage: #{__FILE__} <key> <study_id>"
  exit(1)
end

pb = Piggybank.logged_in_from_file keyfile

subjects = pb.list_subjects(study_id)
pp subjects