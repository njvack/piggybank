#!/usr/bin/env ruby

require 'piggybank'
require 'pp'

study_id = ARGV[0]
pb = Piggybank.logged_in_from_file(nil, nil, "https://chronus.mrn.org/")

instruments = pb.list_instruments(study_id)
pp instruments

