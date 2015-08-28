# Part of the Piggybank library for interacting with COINS
# Copyright 2014 Board of Regents of the University of Wisconsin System
# Released under the MIT license; see LICENSE
require 'base64'

class Piggybank
  ##
  # Demographic and other metadata about a subject in COINS.
  #
  # Note that sometimes a Subject is sometimes created with just an URSI,
  # and then demographic information is all filled out with 
  # Piggybank::get_demographics
  class Subject
    # The canonical anonymized identifier for an individual subject in COINS.
    # Usually consists of the prefix +M+ and a bunch of digits.
    attr_accessor :ursi
    attr_accessor :first_name
    attr_accessor :middle_name
    attr_accessor :last_name
    attr_accessor :suffix
    attr_accessor :gender
    attr_accessor :birth_date
    attr_accessor :address_1
    attr_accessor :address_2
    attr_accessor :city
    attr_accessor :state
    attr_accessor :zip
    attr_accessor :country
    
    # Global notes about a subject in COINS
    attr_accessor :notes
    attr_accessor :phone_1
    attr_accessor :phone_2
    attr_accessor :email
    
    ##
    # Weird Base64 encoded version of URSI required for Piggybank::SubjectViewAction
    def ursi_key
      Base64.encode64("s:#{@ursi.length}:\"#{@ursi}\";")
    end
  end

end
