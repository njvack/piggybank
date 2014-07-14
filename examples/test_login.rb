#!/usr/bin/env ruby
# Very simply test login
# call like test_login.rb <username> <password>

require 'piggybank'

username = ARGV[0]
password = ARGV[1]

if !password
  puts "Usage: #{__FILE__} <username> <password>"
  exit(1)
end

pb = Piggybank.new()
pb.login username, password

if pb.logged_in?
  puts "login success!"
else
  puts "login failed :("
end
