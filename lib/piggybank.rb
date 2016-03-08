# Part of the Piggybank library for interacting with COINS
# Copyright 2014 Board of Regents of the University of Wisconsin System
# Released under the MIT license; see LICENSE

require 'mechanize'
require 'nokogiri'
require 'uri'
require 'json'

##
# Piggybank is a small library to allow scripts to interact with MRN's
# COINS database for neuroimaging data.
#
# At its heart, it's a little mechanize-based scraper and a boatload
# of regular expressions.

class Piggybank
  DEFAULT_URL = "https://chronus.mrn.org"

  ##
  # +agent+ stores a link to the Mechanize agent
  attr_accessor :agent

  ##
  # +url_base+ stores the base COINS URL to use (so you can point to the 
  # sandbox, for example)
  attr_accessor :url_base


  ##
  # Create a new blank, unconnected instance of piggybank.
  #
  # Consider using the Piggybank.logged_in_from_file method
  # or Piggybank.logged_in_from_key
  def initialize(agent=nil, url_base=DEFAULT_URL)
    @agent = agent
    @url_base = url_base
    if @agent.nil?
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Firefox'
    end
  end

  class << self
    ##
    # Initialize a piggybank instance with a given key token.
    def logged_in_from_key(key, agent=nil, url_base=DEFAULT_URL)
      pb = self.new(agent, url_base)
      pb.login_from_key(key)
      pb
    end

    ##
    # Initialize a piggybank instance from a given shell key file.
    #
    # (Download these files from piggybank by going to the menu in
    # the upper left and choosing "Get Shell-Access-Key")
    def logged_in_from_file(key_file=nil, agent=nil, url_base=DEFAULT_URL)
      key_file ||= File.join(ENV['HOME'], "niGet_sh.key")
      key = File.read(key_file).strip()
      pb = self.new(agent, url_base)
      pb.login_from_key(key)
      pb
    end
  end

  ##
  # Using a key, login via the shell login function in COINS
  #
  # Easier to use by just calling Piggybank.logged_in_from_file
  def login_from_key(key)
    form_action = "#{@url_base}/cas/shlogin.php"
    page = @agent.post form_action, {
      :uk => URI.decode_www_form_component(key)
    }
    page
  end

  ##
  # WARNING: This method raises a warning from coins, but still seems to work. 
  # There's a more complex version that uses the normal login page but it is
  # quite horrible, with randomly-named form parameters written by
  # javascript.
  def login(username, password)
    form_action = "#{@url_base}/micis/remote/loginPopupValidation.php"
    page = @agent.post form_action, {
      :username => username,
      :pwd => password,
      :appName => "MICIS"
    }
    page
  end

  ##
  # Are we logged in?
  def logged_in?
    act = StudyListAction.new(self)
    act.get
    !(act.redirected_to_login?)
  end

  ##
  # Return a list of Study actions using StudyListAction
  def list_studies
    act = StudyListAction.new(self)
    act.get
  end

  ##
  # Return a list of Subject objects given a study_id using SubjectListAction
  def list_subjects(study_id)
    act = SubjectListAction.new(self)
    act.get(study_id)
  end

  ##
  # Metaportals are strange in COINS and can contain data
  # (such as anchor dates) which doesn't exist in other
  # demographics sources. This fetches them using MetaportalSubjectListAction.
  #
  # You must supply the metaportal URL yourself because they
  # are customized per portal. (I think.)
  def list_subjects_from_metaportal(url)
    act = MetaportalSubjectListAction.new(self)
    act.get(url)
  end

  ##
  # Given an URSI, get demographics data in a Subject object.
  #
  # Wrapper for get_demographics
  def get_demographics_by_ursi(ursi)
    s = Subject.new
    s.ursi = ursi
    s = get_demographics(s)
    s
  end
  
  def get_tags_by_ursi(ursi)
    s = Subject.new
    s.ursi = ursi
    s = get_tags(s)
    s
  end

  ##
  # Given a Subject object, get demographics data using SubjectViewAction.
  #
  # Wrapped by get_demographics_by_ursi
  def get_demographics(subject)
    act = SubjectViewAction.new(self)
    act.get(subject)
  end
  
  ##
  # Given a Subject object, get tags data using SubjectViewAction.
  #
  # Wrapped by get_demographics_by_ursi
  def get_tags(subject)
    act = SubjectViewAction.new(self)
    act.get_tags(subject)
  end

  ##
  # Given a study_id, list all instruments in it as a simple 
  # JSON-derived Hash using InstrumentListAction.
  #
  # TODO: Make objects
  def list_instruments(study_id)
    act = InstrumentListAction.new(self)
    act.get(study_id)
  end

  ##
  # Given a study_id and the (text) name of an instrument,
  # locate its internal COINS numeric instrument_id using
  # the results of list_instruments
  def find_instrument_id_by_name(study_id, name)
    instruments = list_instruments study_id
    hash = instruments.find { |i| i["label"] == name }
    if hash
      hash["instrument_id"]
    else
      nil
    end
  end

  ##
  # Given a study_id, instrument_id, and an optional URSI,
  # fetch a list of available assessments that match
  # in a Hash by assessment_id using AssessmentsDownloadAction
  def get_assessments(study_id, instrument_id, ursi: nil)
    act = AssessmentsDownloadAction.new(self)
    act.get(study_id, instrument_id, ursi)
  end

  ##
  # Given a study_id, instrument_id, and an optional URSI,
  # fetch a list of available assessments that match
  # in a Hash by assessment_id using AssessmentsDownloadAction
  def get_assessment_details_by_id(study_id, assessment_id)
    act = AssessmentDetailsDownloadAction.new(self)
    act.get(study_id, assessment_id)
  end

  ##
  # Fetch a given instrument's assessment details for study id and 
  # optional URSI, using AssessmentsDownloadAction and
  # AssessmentDetailsDownloadAction.
  #
  # (Keep in mind there may be more than one instance, even for a single URSI)
  #
  # Returns a list of AssessmentEntry objects.
  def get_assessment_details(study_id, instrument_id, ursi: nil)
    act = AssessmentsDownloadAction.new(self)
    assessments = act.get(study_id, instrument_id, ursi)
    assessments.map do |k,v|
      details = AssessmentDetailsDownloadAction.new(self)
      details.get(study_id, k)
    end
  end

  ##
  # Fetch query builder result CSV(s) using list_subjects and 
  # QueryBuilderAction.
  #
  # returnType can be:
  #   - :mostComplete => "Most complete (Cs, 1s and 2s, 1s if no Cs or 2s, and 1s and 2s if Fs)"
  #   - :onlyDoubleEntryComplete => "Only Double Entry Complete Records (Cs)"
  #   - :all => "Every Assessment Record"
  #   - nil or something else => UNKNOWN CHAOS EVENT OCCURS
  def get_query_builder_results(study_id, instrument_names, ursis: nil, returnType: :mostComplete)
    if ursis.nil?
      # First get all ursis in study - this is what QBR does internally too I think
      subjects = list_subjects(study_id)
      ursis = subjects.map {|s| s.ursi}
    end
    act = QueryBuilderAction.new(self)
    act.get(study_id, instrument_names, ursis, optReturnType: returnType)
  end


  ##
  # Mixin for Action helpers
  module ActionUtils
    ##
    # Simple single quote stripper
    def strip_quotes(str)
      str.gsub(/\A'|'\Z/, '')
    end
  end

  ##
  # Wrapper class for different types of 
  class Action
    include Piggybank::ActionUtils
    ##
    # Create an instance with a reference to the Piggybank instance and its Mechanize agent
    def initialize(piggybank)
      @piggybank = piggybank
      @agent = piggybank.agent
    end

    ##
    # Quick helper check to see if we have been redirected
    # to the login page for some reason
    def redirected_to_login?
      @agent.page.body.match "#{@piggybank.url_base}/cas/login.php"
    end

    ##
    # The ASMT interface in COINS has a little dropdown at the top
    # which puts the "actively selected study" into a cookie.
    #
    # This mirrors that behavior and is used by Actions that
    # need to swap that active study.
    def switch_active_study(study_id)
      url = "#{@piggybank.url_base}/micis/asmt/manage/remote.php"
      @agent.get url, {
        "type" => "updateActiveStudy",
        "id" => study_id
      }
    end

  end

  ##
  # List all studies by digging around in JSON
  class StudyListAction < Action
    def get
      p = @agent.get "#{@piggybank.url_base}/micis/study/index.php?action=list"
      studies_json_rx = /var studiesMeta = ([^;]+)/
      studies_json = p.body[studies_json_rx, 1]
      study_data = JSON.parse(studies_json)
      study_data.map {|sd|
        s = Piggybank::Study.new
        s.study_number = sd["hrrc_num"]
        s.name = sd["label"]
        s.irb_number = sd["irb_number"]
        s.study_id = sd["study_id"]
        s
      }
    end
  end

  ##
  # List all Subjects by querying listSubjects.
  # 
  # Currently pulls them out by looking for M______ URSI patterns.
  class SubjectListAction < Action
    def get(study_id)
      p = @agent.get "#{@piggybank.url_base}/micis/subject/index.php?action=listSubjects&study_id=#{study_id}&DoGetStudySubjects=true"
      # subject_data_ary = p.body.scan(/\[('M[^\]]+)\]/)
	  # Looks like it was formatted before as [M{digits}], for example [M12345678], but that's gone so now just look
	  # for a capital M followed by exactly 8 numbers, aka an URSI.
	  subject_data_ary = p.body.scan(/(M\d{8})/)
      subject_data_ary.map {|sda|
        d = sda[0]
        s = Piggybank::Subject.new
        s.ursi = d[/M\d+/] # URSIs start with M
        s
      }
    end
  end

  ##
  # Get the subject listing from a given metaportal in a Hash.
  #
  # Currently only tested on the BBB metaportal.
  # 
  # FUTURE: Could be shifted to use the metaportal's +downloadcsv.php+
  # functionality, but sadly right now that CSV doesn't include the
  # anchor date, which is the only reason we are accessing the metaportal in 
  # the first place.
  class MetaportalSubjectListAction < Action
    def get(url)
      #response = @agent.get(url + "subject/downloadcsv.php?ds=listsubjects").content
      #CSV.parse(response)
      p = @agent.post(url + "subject/", { :ursi => "", :site_id => "0", :subjectTypeID => "0", :doQuery => "Show List" })
      data = p.search('table.tableContainer tr').map do |row| 
        row_output = row.search('td').map do |cell|
          text = cell.text.strip
          text.gsub!(/[\u00a0\n]/, '') # Some kind of weird non-breaking space COINS throws in
          text.gsub!(/[\u00c2\n]/, '') # Some weird upper-ascii thing COINS throws in as a separator? Or maybe a Unicode translation issue?
          text
        end
        # First column is a details link
        row_output.shift
        row_output[4] = Date.parse row_output[4] if row_output[4]
        row_output[5] = Date.parse row_output[5] if row_output[5]
        row_output
      end
      # First row is a header
      data.shift
      # Hash by URSI
      Hash[data.collect {|v| [v[0], v] }] 
    end
  end

  ##
  # Return demographic details in a Subject
  class SubjectViewAction < Action
    FIELD_MAP = {
      "First Name:" => :first_name,
      "Middle Name:" => :middle_name,
      "Last Name:" => :last_name,
      "Suffix:" => :suffix,
      "Birth Date:" => :birth_date,
      "Gender:" => :gender,
      "Address Line 1:" => :address_1,
      "Address Line 2:" => :address_2,
      "City:" => :city,
      "State:" => :state,
      "Postal Code:" => :zip,
      "Country:" => :country,
      "Email Address:" => :email,
      "Notes:" => :notes,
      "Phone 1:" => :phone_1,
      "Phone 2:" => :phone_2,
    }
    def get(subject)
      p = @agent.get "#{@piggybank.url_base}/micis/subject/index.php?action=view&ursi=#{subject.ursi_key}"
      data_hash = Hash[p.search("td.frmLabel").map {|result|
        [result.text, result.next_element.text]
      }]
      out = subject.dup
      FIELD_MAP.each do |coins_field, pb_field|
        out.send "#{pb_field}=", data_hash[coins_field]
      end
      out
    end
  
    def get_tags(subject)
	# COINS displays subject tags in two ways: If there's only one tag, it'll be displayed
	# via 2 'editor' tables, ready for the user to edit. The tag name is shown in a SELECT
	# (pull-down menu) with the tag name as the OPTION that is SELECTED. And the tag value
	# is in a corresponding editable text INPUT in a second table.
	# If there are more than 1 tag, they'll all be displayed in a single table, with the tag
	# names in the first column and the tag values in the last column.

	  tags = Hash.new
      p = @agent.get "#{@piggybank.url_base}/micis/subject/index.php?action=extideditor&ursi=#{subject.ursi_key}"
	  htmlNodes = Nokogiri::HTML(p.body)
	  multiTagTable = htmlNodes.xpath("//table[@id='subject_tags_table']")
	  if !multiTagTable.nil? and multiTagTable.size > 0
	   tagRows = multiTagTable.search("tr")
	   tagRows.each do |row|
		tagRowCells = row.search("td")
		tagName = tagRowCells[0].content.to_s
		tagValue = tagRowCells[2].content.to_s
		if tagName != "Type"	# Skip the header row of the table
		  tags[tagName] = tagValue
		end
	   end  # do
	  else
		  singleTagTables = htmlNodes.search("table")
		  selectorText = singleTagTables.xpath("//tr/td/select[@name='subject_tag_id']").to_s
		  # We're looking for the OPTION from the SELECT menu that is SELECTED. We want the
		  # displayed text from that. Which is between "<option ... selected>" and "<whatever ...>".
		  # So the regex should lazily (not greedily) pull all the text (aka "(.*?)" ) between them.
		  tagName = selectorText[/selected>(.*?)</, 1]
		  inputText = singleTagTables.xpath("//tr/td/input[@name='value']").to_s
		  # There's probably a way to pull this out using xpath(), but this regex works and is easy.
		  tagValue = inputText[/value=\"(.*?)\"/, 1]
		  if !tagName.nil? and !tagValue.nil?
			tags[tagName] = tagValue
		  end
	  end
	  return tags
    end
  end

  
  ##
  # Pull instruments from the study instrument page, parsing
  # the JSON directly as a simple Hash
  class InstrumentListAction < Action
    def get(study_id)
      p = @agent.get "#{@piggybank.url_base}/micis/remote/getStudyData.php", {
        :type => "instruments",
        :id => study_id
      }
      JSON.parse(p.body)
    end
  end

  ##
  # Given study_id, instrument_id, and optional ursi, return a Hash of 
  # Assessment objects keyed by assessment_id.
  #
  # Uses switch_active_study to get the correct cookie information set up for 
  # the currently active study.
  class AssessmentsDownloadAction < Action
    def get(study_id, instrument_id, ursi)
      # First we have to do whatever onAsmtStudyChange(asmt_study_id) is doing
      switch_active_study study_id
      
      # Now we can just fetch the search by instrument_id
      options = {
        "action" => "search",
        "instrument_id" => instrument_id,
        "dataentry_type_id" => "1",
        "ownersOnly" => "off",
        "DoSearch" => "true",
      }

      if ursi
        options["ursi"] = ursi
      end

      url = "#{@piggybank.url_base}/micis/asmt/manage/index.php"
      
      #@agent.log = Logger.new(STDERR)
      p = @agent.get url, options

      data = p.search('table#asmt_grid tr').map do |row| 
        r = row.search('td').map do |cell|
          text = cell.text.strip
          text.gsub(/[\u00a0\n]/, '') # Some kind of weird non-breaking space COINS throws in
        end

        a = Piggybank::Assessment.new
        a.assessment_id = r[0]
        a.study_id = study_id
        a.ursi = r[1]
        a.instrument_name = r[2]
        a.rater1 = r[3]
        a.date = Date.parse r[4] if r[4]
        a.site = r[5]
        a.visit = r[6]
        a.visit_instance = r[7]
        a.entry_code = r[8]
        a.entry_start = r[9]
        a.entry_end = r[10]
        a.user = r[11]

        a
      end

      # First row is a header
      data.shift
      # Hash by assessment_id
      Hash[data.delete_if {|v| v.assessment_id == nil}.collect {|v| [v.assessment_id, v] }] 
    end
  end

  ##
  # Download assessment details for a given study_id and assessment_id.
  #
  # Note that study_id doesn't really seem necessary given that COINS should 
  # have unique assessment_id across all studies, but this needs to use 
  # switch_active_study to get the correct cookie information set up for 
  # the currently active study. Hacktastic!
  class AssessmentDetailsDownloadAction < Action
    def get(study_id, assessment_id)
      # Example URL: https://coinstraining.mrn.org/micis/asmt/assessments/index.php?action=responses&id=13876005
      
      # First we have to do whatever onAsmtStudyChange(asmt_study_id) is doing
      switch_active_study study_id
      
      # Now we can just fetch the assessment by id
      options = {
        "action" => "responses",
        "id" => assessment_id,
      }

      url = "#{@piggybank.url_base}/micis/asmt/assessments/index.php"
      
      #@agent.log = Logger.new(STDERR)
      p = @agent.get url, options

      a = Piggybank::AssessmentDetails.new
      a.assessment_id = assessment_id
      a.study_id = study_id

      tables = p.search('table')
      metadata = tables.shift

      # We scrape the metadata at the top of the page
      metadata.search('tr').map do |row| 
        tds = row.search('td')
        label = tds.shift.text.strip
        content = tds.shift.text.strip

        case label
        when /ursi/i
          a.ursi = content
        when /rater/i
          a.rater = content
        when /date/i
          # For some reason, `Date.parse` explodes here
          a.date = content
        when /entry/i
          a.entry_code = content
        when /segment/i
          a.segment = content
        when /rater_completed/i
          a.rater_completed = content
        when /notes/i
          a.notes = content
        when /dx/i
          a.include_in_dx = content
        end
      end

      # Then the tables of "section" data at the bottom,
      # which we aggregate in a big pile for now because 
      # Dan don't understand 'em AT ALL
      #
      # TODO: Understand what happens with multiple attempts at a single assessment?
      a.raw_data = tables.map do |t|
        rows = t.search('tr')
        rows.shift
        rows.map do |r|
          entry_data = r.search('td').map do |cell|
            cell.text.strip
          end
          entry = Piggybank::AssessmentEntry.new a
          entry.column_id = entry_data[0]
          entry.label = entry_data[1]
          entry.instance = entry_data[2]
          entry.response = entry_data[3]
          entry.notes = entry_data[4]
          entry
        end
      end.flatten

      a.data = Hash[ a.raw_data.map { |e| [ e.column_id, e.response ] } ]
      a.labels = Hash[ a.raw_data.map { |e| [ e.column_id, e.label ] } ]

      a
    end
  end

  ##
  # Completely crazy method to automate the COINS query builder.
  #
  # See Piggybank.get_query_builder_results for details on how the options 
  # are used.
  class QueryBuilderAction < Action
    def get(study_id, instrument_names, ursis, optReturnType: :mostComplete)
      opts = {
        :collapseseries => false,
        :demoPieces => [],
        :erpscans => false,
        :fieldSeparator => "u0009",
        :includequestdesc => "yes",
        :includeSALabel => "no",
        :asmtDate => "asmtDate",
        :includeAsmtMeta => "yes",
        :lineSeparator => "u000a",
        :missingDataVal => "-1001",
        :dontKnowVal => "-1002",
        :maxrecordsreturn => 500,
        :optCollapseByURSI => false,
        :orientation => "crossCollapse",
        :scanOrientation => "normalOneCell",
        :outputScanPieces => [],
        :qPieces => [],
        :scanPieces => [],
        :textqualifier => "\"",
        :ursiList => "",
        :ursisInStudy => 0,
        :subjectType => 0,
        :validSpecifiedUrsis => ursis.join(","),
        :visitorientation => "updown",
        :questFormatSegInt => true,
        :questFormatSegInst => true,
        :questFormatEC => false,
        :questFormatSiteCt => false,
        :questFormatSourceCt => false,
        :questFormatRaterCt => false,
        :questFormatQuesInst => true,
        :questFormatDrop1 => true,
        :allQueriedFields => false,
        :limitStSrcRt => true,
        :printFirstOnlyAsmt => false,
        :includeRespLabel => false,
        :includeAllMultiOptions => false,
        :showMissingAsPd => false,
        :preventDateConversion => false,
        :outputNumericAsString => false,
        :asmtBoolLogic => false,
        :scanBoolLogic => false,
        :showOnlyDataUrsis => false,
        :queryHasRecords => false,
        :subjectListType => "ursi",
        :subjectTags => nil,
        :subjectListTagID => nil,
        :subjectListTagContext => ["global"],
        :subjectListTagStudyID => nil,
        :asmtDateOptions => {
          :selected => false,
          :asmtMinDate => nil,
          :asmtMaxDate => nil,
          :asmtMinEntryStartDate => nil,
          :asmtMaxEntryStartDate => nil,
          :asmtMinEntryEndDate => nil,
          :asmtMaxEntryEndDate => nil
        },
        :exportSubjectTags => [],
        # Only included some of the time?
        # :subjectTypeStudy => 0,
      }

      # What kind of return type are we trying for? Mirrors the three 
      # pseudo-checkbox options in the QBR UI, or tries to.
      case optReturnType
      when :onlyDoubleEntryComplete
        opts[:optCentries] = "true"
      when :all
        opts[:returnall] = "true"
      when :mostComplete
        opts[:optMostCompleteEntries] = "true"
      end

      sd_url = "#{@piggybank.url_base}/micis/remote/getStudyData.php"
      qb_url = "#{@piggybank.url_base}/micis/qbBeta/remote.php"

      # First, we need to determine the instruments for this study
      p = @agent.post(sd_url, { :type => "instruments", :id => study_id })
      instruments_json = JSON.parse p.body

      # Then we need to crunch together the set of all questions we want to return.
      outputs = []
      instrument_names.each do |name|
        instrument = instruments_json.find {|i| i["label"] == name}
        if instrument.nil? or not instrument.key?("instrument_id")
          puts "Warning: Instrument not found with name #{name}"
        else
          instrument_id = instrument["instrument_id"]
          q = @agent.post(sd_url, { :type => "questions", :id => instrument_id })
          questions_json = JSON.parse q.body

          questions_json.each do |question|
            outputs << {
              "instrumentId" => instrument_id,
              "instrumentLabel" => name,
              "visitId" => 0,
              "visitLabel" => "All Visits",
              "fieldId" => question["question_id"],
              "fieldLabel" => question["label"],
              "studyId" => study_id,
            }
          end
        end
      end
      

      # Those opts get passed as JSON to the handler, after we cram in
      # all the output pieces for the instruments we want to fetch.
      opts[:outputPieces] = outputs
      json = JSON.generate opts

      @agent.idle_timeout = 30
      @agent.read_timeout = 600

      # Little helper to dump useful stuff when problems happen
      def json_or_error(json, page)
        begin
          result = JSON.parse page.body
        rescue Exception=>e
          raise "Got parse error #{e} in #{page.to_s}, json submitted was #{json}"
        end
        if result.key? "error" then
          raise "Got error in #{page.to_s}, #{result.error}, json submitted was #{json}"
        end
        return result
      end

      # STEP 1: First we see how many results there are
      @agent.post(sd_url, { :type => "getresults", :q => json })

      # STEP 2: Cache sort order, whatever that does
      json_or_error(json, @agent.post(qb_url, { :action => "cacheSortOrder", :q => json }))

      # STEP 3: Cache pivot categories
      # Yes, QBR passes action as both querystring and in POST here.
      # Not sure why but let's do the same!
      json_or_error(json, @agent.post(qb_url + "?action=cachePivotCategories", { :action => "cachePivotCategories", :q => json }))

      # STEP 4: Export file to temp location
      result_json = json_or_error(json, @agent.post(qb_url, { :action => "writeExportFile", :q => json }))
      
      unless result_json.key? "body" then
        raise "No body in #{result_json.to_s}"
      end
        
      # STEP 5: Download that temp location locally and unzip it in pwd
      url = qb_url + "?action=downloadFile&filename=" + result_json["body"]["filename"]
      Dir.mktmpdir do |tmpdir|
        file = File.join(tmpdir, "coins.zip")

        @agent.download(url, file)
        original_dir = Dir.pwd
        Dir.chdir tmpdir
        system("unzip", "-qq", file)

        subdirs = Dir.glob('*').select {|f| File.directory? f and f =~ /^coins/}

        if subdirs.length != 1
          raise "Expected 1 directory, got #{subdirs}"
        end

        Dir.chdir original_dir

        files = Dir.glob(File.join(tmpdir, subdirs[0], "*"))
        files.map do |f|
          name = File.basename f
          FileUtils.mv(f, File.join(original_dir, name))
          name
        end
      end
    end
  end


  ##
  # If Piggybank throws an error, it will use one of these instead of 
  # RuntimeError. Someday.
  class Error < RuntimeError

  end

end


require 'piggybank/study'
require 'piggybank/subject'
require 'piggybank/assessment'
require 'piggybank/assessment_details'
require 'piggybank/assessment_entry'
