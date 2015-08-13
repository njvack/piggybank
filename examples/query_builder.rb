#!/usr/bin/env ruby

ENV['GEM_HOME']="/study/infmri/COINS/scripts/lib/gems"
$LOAD_PATH.unshift("/home/fitch/git/piggybank/lib")
require 'piggybank'
require 'pp'

study_id = ARGV[1]
if not study_id then
    study_id = 6840
end

ursi = ARGV[0]
if not ursi then
    ursi = "M53780807,M53791621"
end

pb = Piggybank.logged_in_from_file(nil, nil, "https://chronus.mrn.org/")

results = pb.get_query_builder_results_for_study_and_ursi(study_id, ursi)
pp results
