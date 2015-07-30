class Piggybank
  class AssessmentEntry
    attr_accessor :assessment_id
    attr_accessor :study_id
    attr_accessor :ursi
    attr_accessor :column_id
    attr_accessor :label
    attr_accessor :instance
    attr_accessor :response
    attr_accessor :notes

    def initialize(details)
      if details
        @assessment_id = details.assessment_id
        @study_id = details.study_id
        @ursi = details.ursi
      end
    end
  end
end


