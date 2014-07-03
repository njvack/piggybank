##
# Piggybank is a small library to allow scripts to interact with MRN's
# COINS database for neuroimaging data.
#
# At its heart, it's a little mechanize-based scraper and a boatload
# of regular expressions.

require 'mechanize'

class Piggybank
  attr_accessor :agent
  def initialize(agent=nil)
    @agent = agent
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
    form_action = "https://chronus.mrn.org/micis/remote/loginPopupValidation.php"
    page = @agent.post form_action, {
      :username => username,
      :pwd => password,
      :appName => "MICIS"
    }
  end

  def logged_in?
    act = StudyListAction.new(@agent)
    act.get
    !(act.redirects_to_login?)
  end

  def list_studies
    StudyListAction.new(@agent)
  end

  class Action
    def initialize(agent)
      @agent = agent
    end

    def redirects_to_login?
      @agent.page.body.match "https://chronus.mrn.org/cas/login.php"
    end

  end

  class StudyListAction < Action
    def get
      @agent.get "https://chronus.mrn.org/micis/study/index.php?action=list"
    end
  end

  class Error < RuntimeError

  end
end