#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require 'piggybank'
require 'pp'

key = ARGV[0]
study_id = ARGV[1]
if !key
  puts "Usage: #{__FILE__} <key> <study_id>"
  exit(1)
end

pb = Piggybank.new()
pb.login_from_key key

subjects = pb.list_subjects(study_id)
pp subjects