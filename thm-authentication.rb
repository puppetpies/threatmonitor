########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor User Administration
# 
# Extends the functionality of the Thm module adding Authorization
# Adding Authentication to the Privileges model
#
########################################################################

require "#{File.dirname(__FILE__)}/lib/thm.rb"
require "#{File.dirname(__FILE__)}/thm-privileges.rb"

conf = Thm::FileServices.new
conf.thmhome?

module Thm::Authorization

  class Authentication < Thm::DataServices
    
    attr_reader :thmsession
    attr_accessor :thmsesslock
    
    def initialize
      super
      @debug = true
    end
    
    def login(username, password)
      obj = Thm::Authorization::Privileges.new
      pwhash = obj.mkhash(password)
      sqlusrcnt = "SELECT count(*) as num FROM users WHERE username = '#{username}' AND password = '#{pwhash}'"
      resusrcnt = @conn.query("#{sqlusrcnt}")
      rowusrcnt = resusrcnt.fetch_hash
      puts "#{rowusrcnt["num"].to_i}"
      if rowusrcnt["num"].to_i == 1
        puts "Authentication Success"
        @thmsession = Tools::guid.to_s
        @thmsesslock = "OK"
      else
        @thmsession = "failure"
        @thmsesslock = "FAILURE"
        puts "\e[1;31m\Failure to Authenticate \e[0m\ "
      end
    end
    
    def login_session?
      if @thmsession != "failure" or @thmsession != nil
        return true
      else
        return false
      end 
    end
    
    def logout
      @thmsession = nil
      @thmsesslock = "DEADBEEF"
    end
    
  end

end
