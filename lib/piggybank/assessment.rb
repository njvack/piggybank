class Piggybank
  ##
  # Represents a single instance of an assessment, which is a particular run 
  # of a particular instrument by a particular subject. This contains just the 
  # top-level metadata about the assessment, and you must retrieve 
  # AssessmentDetails to get full question and answer data.
  #
  # Keep in mind that there can be more than one assessment for an instrument 
  # and URSI in coins, with different rater and visit and entry_code and so on.
  class Assessment
    # The internal unique ID used by COINS for an individual assessment instance
    attr_accessor :assessment_id

    # The Study unique id associated with this assessment
    attr_accessor :study_id

    # The URSI of the subject that this assessment is for
    attr_accessor :ursi

    # The instrument name that goes with this assessment
    attr_accessor :instrument_name

    # The rater (I don't know why it's rater1 and we don't have rater2)
    attr_accessor :rater1

    # The date the assessment happened, or was last updated?
    attr_accessor :date

    # TODO: The site the assessment happened at?
    attr_accessor :site

    # TODO: The visit this assessment happened in
    attr_accessor :visit

    # TODO: No idea what this means
    attr_accessor :visit_instance

    # Entry code is a single letter. "C" means complete. There are a lot of 
    # them and I don't know what they all mean.
    #
    # TODO: Document all the entry codes.
    attr_accessor :entry_code

    # When the entry started
    attr_accessor :entry_start

    # When the entry ended
    attr_accessor :entry_end

    # The user who did the entry of this assessment
    attr_accessor :user
  end
end

