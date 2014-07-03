#!/usr/bin/env ruby

require 'mechanize'
require 'pp'
require 'json'
require 'ostruct'
require 'base64'

def jsonify_quotes(str)
  str.gsub('"', '\"').gsub("'", '"')
end

def coins_login_simple(agent, username, password)
  page = agent.post "https://chronus.mrn.org/micis/remote/loginPopupValidation.php", {
    :username => username,
    :pwd => password,
    :appName => "MICIS"
  }
  page
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

def parse_study_array(ary)
  obj = OpenStruct.new()
  list_thing = ary[2]
  results = list_thing.match /([^^]+)\^/
  obj.name = results[1]
  results = list_thing.match /study_id=(\d+)/
  obj.study_id = results[1]
  obj.other_id = ary[0]
  obj
end

def list_studies(agent)
  page = agent.get "https://chronus.mrn.org/micis/study/index.php?action=list"
  study_list_match = page.body.match(/parent\.list=(.*?);/)
  study_list_json = jsonify_quotes(study_list_match[1])
  study_list = JSON.parse(study_list_json)
  study_list.map {|data| parse_study_array(data)}
end

def list_subjects(agent, study_id)
  page = agent.get("https://chronus.mrn.org/micis/subject/index.php?action=getStudy&study_id=#{study_id}&DoGetStudySubjects=true")
  rx = /\[('M[^\]]+)\]/
  matches = page.body.scan rx
  #list_data = page.body.match /parent\.list=(\[\[.*?\]);/m
  #list_data[1];
  matches.map {|matches|
    m = matches[0]
    obj = OpenStruct.new
    obj.ursi = m[/M\d+/]
    view_key_match = m.match(/ursi=(.*?==)/)
    obj.ursi_key = view_key_match[1]
    obj.ursi_key_decoded = Base64.decode64(obj.ursi_key)
    obj
  }
end

def ursi_key(ursi)
  # They're strings like "s:9:\"M53729038\";", base64 encoded
  "s:9:\"#{ursi}\";"
end

def ursi_key_encoded(ursi)
  Base64.urlsafe_encode64(ursi_key(ursi))
end

def subject_metadata(agent, ursi_key)
  page = agent.get("https://chronus.mrn.org/micis/subject/index.php?action=view&ursi=#{ursi_key}")
  out = {}
  page.search("td.frmLabel").each do |result|
    out[result.text] = result.next_element.text
  end
  out
end

agent = Mechanize.new
username = ARGV[0]
password = ARGV[1]
study_id = ARGV[2]
#page = coins_login_simple(agent, username, password)
#subjects = list_subjects agent, study_id
#pp subject_metadata agent, subjects[0].ursi_key

