#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require '../lib/piggybank'
require 'pp'

username = ARGV[0]
password = ARGV[1]

if !password
  puts "Usage: #{__FILE__} <username> <password>"
  exit(1)
end

pb = Piggybank.new()
pb.login username, password

studies = pb.list_studies
pp studies