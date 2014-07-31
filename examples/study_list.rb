#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require 'piggybank'
require 'pp'

key = ARGV[0]

if !key
  puts "Usage: #{__FILE__} <key>"
  exit(1)
end

pb = Piggybank.new()
pb.login_from_key key

studies = pb.list_studies
pp studies