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

require './thm-privileges.rb'

module Thm::Authorization

  class Authentication < Thm::DataServices
    
    attr_reader :thmsession
    
    def login(username, password)
      obj = Thm::Authorization::Privileges.new
      pwhash = obj.mkhash(password)
      sqlusrcnt = "SELECT count(*) as num FROM users WHERE username = '#{username}' and password '#{pwhash}';"
      resusrcnt = @conn.query("#{sqlusrcnt}")
      rowusrcnt = resusrcnt.fetch_hash
      puts "#{rowusrcnt["num"].to_i}"
      if rowusrcnt["num"].to_i == 1
        puts "Authentication Success"
        @thmsession = Tools::guid
      else
        @thmsession = "failure"
        puts "Failure to Authenticate"
      end
    end
    
    def login_status?
      if @thmsession != "failure" or @thmsession != nil
        return true
      else
        return false
      end 
    end
    
    def logout
      @thmsession = nil
    end
    
  end

end
