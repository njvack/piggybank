##
# Piggybank is a small library to allow scripts to interact with MRN's
# COINS database for neuroimaging data.
#
# At its heart, it's a little mechanize-based scraper and a boatload
# of regular expressions.

require 'mechanize'

class Piggybank
  attr_accessor :agent
  attr_accessor :url_base

  def initialize(agent=nil, url_base="https://chronus.mrn.org")
    @agent = agent
    @url_base = url_base
    if @agent.nil?
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Firefox'
    end
  end

  def login(username, password)
    # This method raises a warning from coins but still seems to work. There's
    # a more complex version that uses the normal login page but it is
    # quite horrible, with randomly-named form parameters written by
    # javascript.
    form_action = "#{@url_base}/micis/remote/loginPopupValidation.php"
    page = @agent.post form_action, {
      :username => username,
      :pwd => password,
      :appName => "MICIS"
    }
  end

  def logged_in?
    act = StudyListAction.new(self)
    act.get
    !(act.redirected_to_login?)
  end

  def list_studies
    StudyListAction.new(self)
  end

  class Action
    def initialize(piggybank)
      @piggybank = piggybank
      @agent = piggybank.agent
    end

    def redirected_to_login?
      @agent.page.body.match "#{@piggybank.url_base}/cas/login.php"
    end

  end

  class StudyListAction < Action
    def get
      @agent.get "#{@piggybank.url_base}/micis/study/index.php?action=list"
    end
  end

  class Error < RuntimeError

  end
end