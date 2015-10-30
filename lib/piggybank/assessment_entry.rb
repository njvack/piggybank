class Piggybank
  ##
  # Raw data for a particular question and response in an AssessmentDetails object
  class AssessmentEntry
    # The internal unique ID used by COINS for an individual assessment instance
    attr_accessor :assessment_id
    
    # The Study unique id associated with this assessment
    attr_accessor :study_id

    # The URSI of the subject that this assessment is for
    attr_accessor :ursi

    # The question identifier for this question
    attr_accessor :column_id

    # The human-readable label for this question
    attr_accessor :label

    # The instance (TODO: What does this mean in COINS-land?)
    attr_accessor :instance

    # The actual value entered for this question
    attr_accessor :response

    # Any notes about this value stored in COINS
    attr_accessor :notes

    ##
    # Initialize an entry and pre-fill some of its information from an 
    # AssessmentDetails object
    def initialize(details)
      if details
        @assessment_id = details.assessment_id
        @study_id = details.study_id
        @ursi = details.ursi
      end
    end
  end
end


