#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require '../lib/piggybank'
require 'pp'

username = ARGV[0]
password = ARGV[1]
study_id = ARGV[2]
if !password
  puts "Usage: #{__FILE__} <username> <password> <study_id>"
  exit(1)
end

pb = Piggybank.new()
pb.login username, password

subjects = pb.list_subjects(study_id)
subjects.each do |subj|
  detailed = pb.get_demographics(subj)
  pp detailed
end