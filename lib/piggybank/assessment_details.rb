class Piggybank
  ##
  # Full question and answer data for a given assessment_id.
  #
  # Contains similar but not identical metadata to the Assessment,
  # because that's how it's exposed through the COINS interface.
  #
  # TODO: Merge Assessment and AssessmentDetails somehow cleanly
  class AssessmentDetails
    # The internal unique ID used by COINS for an individual assessment instance
    attr_accessor :assessment_id
    
    # The Study unique id associated with this assessment
    attr_accessor :study_id

    # The URSI of the subject that this assessment is for
    attr_accessor :ursi

    # The rater
    attr_accessor :rater

    # The date the assessment happened, or was last updated?
    attr_accessor :date
    
    # The entry code. See Assessment::entry_code
    attr_accessor :entry_code

    # The segment. May somehow be related to Assessment::visit or Assessment::site?
    attr_accessor :segment

    # Is the rater done?
    attr_accessor :rater_completed

    # Rater or administrative notes
    attr_accessor :notes

    # Include in diagnosis?
    attr_accessor :include_in_dx

    # Raw data as it came out of the tables onscreen in the assessment data, 
    # converted into AssessmentEntry objects
    attr_accessor :raw_data

    # A Hash keyed by column_id (which is each question in the assessment)
    # to response value
    attr_accessor :data

    # A Hash keyed by column_id storing the human-readable labels of each 
    # question in the assessment
    attr_accessor :labels
  end
end

