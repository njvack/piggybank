#!/usr/bin/env ruby

require 'mechanize'
require 'pp'
require 'json'

def jsonify_quotes(str)
  str.gsub('"', '\"').gsub("'", '"')
end

def coins_login(agent, username, password)
  page = agent.get "https://chronus.mrn.org/cas/login.php?rp=https%3A%2F%2Fchronus.mrn.org%2Fmicis%2Findex.php%3Fsubsite%3Dasmt"
  uname_match = page.body.match /name="([^"]+)" placeholder="Username/
  uname_field = uname_match[1]
  pw_match = page.body.match /name="([^"]+)" placeholder="Pa\$\$w0rd/
  pw_field = pw_match[1]

  f = Mechanize::Form.new(page)
  f.method = "POST"
  f.action = "/cas/login.php"
  f.add_field! "ref", "https://chronus.mrn.org/micis/index.php"
  f.add_field! uname_field, username
  f.add_field! pw_field, password

  page = agent.submit(f)
end

def list_studies(agent)
  page = agent.get "https://chronus.mrn.org/micis/study/index.php?action=list"
  study_list_match = page.body.match(/parent\.list=(.*?);/)
  study_list_json = jsonify_quotes(study_list_match[1])
  JSON.parse(study_list_json)
end

agent = Mechanize.new
coins_login(agent, ARGV[0], ARGV[1])

pp list_studies(agent)