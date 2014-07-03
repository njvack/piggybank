# Part of the Piggybank library for interacting with COINS
# Copyright 2014 Board of Regents of the University of Wisconsin System
# Released under the MIT license; see LICENSE

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
    act = StudyListAction.new(self)
    act.get
  end

  module ActionUtils
    def strip_quotes(str)
      str.gsub(/\A'|'\Z/, '')
    end
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
    include Piggybank::ActionUtils

    def get
      p = @agent.get "#{@piggybank.url_base}/micis/study/index.php?action=list"
      # Yields something like "[[stuff]]"
      puts p.body
      study_list = p.body.match(/parent\.list=\[(.*?)\];/)[1]
      study_arrays = study_list.scan /\[(.*?)\]/
      study_arrays.map {|ary|
        study_bits = ary[0].split(",").map {|bit| strip_quotes(bit)}
        s = Piggybank::Study.new
        s.study_number = study_bits[0]
        s.irb_number = study_bits[1]
        s.status = study_bits[3]
        # The name and id are in a string that looks like
        # WISCDEMO2^javascript:parent.loadPage(\"https://chronus.mrn.org/micis/study/index.php?action=view&study_id=6160\")^pageIframe
        more_bits = study_bits[2].split('^')
        s.name = more_bits[0]
        s.study_id = more_bits[1].match(/study_id=(\d+)/)[1]
        s
      }
    end
  end

  class Error < RuntimeError

  end

end



require 'piggybank/study'