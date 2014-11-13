#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require 'piggybank'

keyfile = ARGV[0]

if !keyfile
  puts "Usage: #{__FILE__} <key>"
  exit(1)
end

pb = Piggybank.logged_in_from_file keyfile
puts pb.agent.page.body

if pb.logged_in?
  puts "login success!"
else
  puts "login failed :("
end
