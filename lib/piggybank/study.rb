# Part of the Piggybank library for interacting with COINS
# Copyright 2014 Board of Regents of the University of Wisconsin System
# Released under the MIT license; see LICENSE

class Piggybank
  ##
  # Stores the metadata about a particular study.
  class Study
    # The IRB number assigned to this study
    attr_accessor :irb_number

    # The study number assigned to this study
    attr_accessor :study_number

    # The internal COINS id for the study, used throughout Piggybank for 
    # identifying an individual Study.
    attr_accessor :study_id

    # The current status of the study. TODO: Enumerate what this could actually be.
    attr_accessor :status

    # The somewhat-friendly user-facing name (abbreviation) of the study
    attr_accessor :name
  end
end
