#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require 'piggybank'
require 'pp'

keyfile = ARGV[0]

if !keyfile
  puts "Usage: #{__FILE__} <key>"
  exit(1)
end

pb = Piggybank.logged_in_from_file keyfile

studies = pb.list_studies
pp studies