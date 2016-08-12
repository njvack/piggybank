#!/usr/bin/env ruby

require 'piggybank'
require 'pp'

ursi = ARGV[0]
instrument = ARGV[1]
study_id = ARGV[2]

pb = Piggybank.logged_in_from_file(nil, nil, "https://chronus.mrn.org/")

instrument_id = pb.find_instrument_id_by_name(study_id, instrument)
assessment_details = pb.get_assessment_details(study_id, instrument_id, ursi: ursi)

keys = ["study_id", "instrument", "ursi"] + assessment_details[0].data.keys

CSV do |out|
  out << keys
  assessment_details.each do |d|
    out << [ study_id, instrument, d.ursi ] + d.data.values
  end
end

