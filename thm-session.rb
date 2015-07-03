########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor User Administration / Dashboard
# Codename: Deedrah
#
# Extends the functionality of the Thm module adding Authorization
# Adding Session Login / Sinatra / Web Interface functionality
#
########################################################################

require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require './thm-authentication.rb'

class Sinatra::Base

  class << self
  
    def getpost(path, opts={}, &block)
      get(path, opts, &block)
      post(path, opts, &block)
    end
    
  end
  
end

module ThmUI extend self

  class Deedrah < Sinatra::Base

    attr_reader :thmsession
    
    set :server, :puma
    set :logging, :true
	
    configure do
      enable :session
    end
    
    before do
      content_type :html
    end
	
    set :title, "Threatmonitor - Packet Analysis Suite"
    set :port, 4567
    set :bind, "0.0.0.0"
    
    def login_status?
      if @sessobj.login_status? == false
        puts "Not logged in"
      end
    end
    
    def get_session_info?
      @thmsession = @sessobj.thmsession
      puts "Sinatra: #{Sinatra::VERSION} / Session Secret: #{self.session_secret} / Thmsession: #{@thmsession}"
    end
    
    def login(username, password)
      @sessobj = Thm::Authorization::Authentication.new
      @sessobj.datastore = "monetdb"
      @sessobj.dbconnect
      @sessobj.login("#{username}", "#{password}")
      if self.login_status?
        puts "\e[1;32m\Welcome to Threatmonitor \e[0m\ "
        puts "Thm Session: #{@sessobj.thmsession}"
        return true
      end
    end
     
    def logout
      @sessobj.logout
      @sessobj.dbclose
    end
    
    # Sinatra routings
    
    getpost '/' do
      
      slim :authenticate
    end
    
    run!
    
  end
  
end

Deedrah.new
