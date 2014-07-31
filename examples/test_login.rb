#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require 'piggybank'

key = ARGV[0]

if !key
  puts "Usage: #{__FILE__} <key>"
  exit(1)
end

pb = Piggybank.new()
page = pb.login_from_key key
puts page.body

if pb.logged_in?
  puts "login success!"
else
  puts "login failed :("
end
