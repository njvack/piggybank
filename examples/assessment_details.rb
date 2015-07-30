#!/usr/bin/env ruby

require 'piggybank'
require 'pp'

study_id = ARGV[2]
if not study_id then
    study_id = 6860
end

instrument = ARGV[1]
if not instrument then
    instrument = "ET"
end

ursi = ARGV[0]
if not ursi then
    ursi = "M53783053"
end

pb = Piggybank.logged_in_from_file keyfile

instrument_id = pb.find_instrument_id_by_name(study_id, instrument)
assessment_details = pb.get_assessment_details(study_id, instrument_id, ursi: ursi)

keys = ["study_id", "instrument", "ursi"] + assessment_details[0].data.keys

# TODO: sane CSV output - what do we do in cases with multiple entries, etc.
CSV do |out|
  out << keys
  assessment_details.each do |d|
    out << [ study_id, instrument, d.ursi ] + d.data.values
  end
end

