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
require 'slim'
require './thm-authentication.rb'

RELEASE = "Deedrah"

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
	
    set :title, "Threatmonitor - Packet Analysis Suite #{RELEASE}"
    set :port, 4567
    set :bind, "0.0.0.0"
    
    def objstart!
      @sessobj = Thm::Authorization::Authentication.new
      @sessobj.datastore = "monetdb"
      @sessobj.dbconnect
    end
    
    # NOTE: Monkey patch Sinatra initialize
    #       If you go to /dashboard without logging in @sessobj it won't have been created
    #       So if you create it objstart! in the Sinatra's initialize your sorted.
    #       Page requests will come in a @sessobj will always exist and be the same one no headaches 
    def initialize(app = nil)
      super()
      objstart! # Little trick here patch so i can get objstart! out of the box!
      @app = app 
      @template_cache = Tilt::Cache.new
      yield self if block_given?
    end

    def login_status?
      if @sessobj.login_status? == false
        puts "Not logged in"
      else
        return true
      end
    end
    
    def get_session_info?
      @thmsession = @sessobj.thmsession
      puts "Sinatra: #{Sinatra::VERSION} / Session Secret: #{self.session_secret} / Thmsession: #{@thmsession}"
    end
    
    def login(username, password)
      @sessobj.login("#{username}", "#{password}")
      if login_status?
        puts "\e[1;32m\Welcome to Threatmonitor \e[0m\ "
        puts "Thm Session: #{@sessobj.thmsession}"
        return true
      else
        return false
      end
    end
     
    def logout
      @sessobj.thmsesslock = "DEADBEEF"
      #@sessobj.logout
      #@sessobj.dbclose
    end
    
    # Sinatra routings
    
    getpost '/' do
      if params[:submit] != nil
        @sessthm = login(params[:username], params[:password])
      end
      if @sessobj.thmsesslock == "OK"
        puts "Session created redirecting to Dashboard ..."
        redirect '/dashboard'
      end
      slim :authenticate
    end
    
    getpost '/dashboard' do
      if @sessobj.thmsesslock != "OK"
        puts "Session doesn't exist redirecting to Login..."
        redirect '/'
      end
      slim :dashboard
    end
    
    getpost '/logout' do
      if @sessobj.thmsesslock == "OK"
        logout
        redirect '/'
      end
      slim :logout
    end
    
    get '/stylesheets/screen.css' do
      send_file 'stylesheets/screen.css', :type => :css
    end
    run!
    
  end
  
end

Deedrah.new
