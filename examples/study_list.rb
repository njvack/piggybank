#!/usr/bin/env ruby

require 'piggybank'
require 'pp'

pb = Piggybank.logged_in_from_file(nil, nil, "https://chronus.mrn.org/")

studies = pb.list_studies
pp studies
