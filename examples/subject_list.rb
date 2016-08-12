#!/usr/bin/env ruby

require 'piggybank'
require 'pp'

pb = Piggybank.logged_in_from_file(nil, nil, "https://chronus.mrn.org/")

subjects = pb.list_subjects(study_id)
pp subjects
