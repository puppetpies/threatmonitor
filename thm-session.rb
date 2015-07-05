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
require 'chartkick'
require 'sinatra/base'
require 'slim'
require "#{File.dirname(__FILE__)}/thm-authentication.rb"

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

  class JSGraphing
    include Chartkick::Helper
  end
  
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

    def login_session?
      if @sessobj.login_session? == false
        puts "Not logged in"
      else
        return true
      end
    end
    
    def get_session_info?
      puts "Sinatra: #{Sinatra::VERSION} / Thmsession: #{@sessobj.thmsession}"
    end
    
    def login(username, password)
      @sessobj.login("#{username}", "#{password}")
      if login_session?
        puts "\e[1;32m\Welcome to Threatmonitor \e[0m\ "
        puts "Thm Session: #{@sessobj.thmsession}"
        return true
      else
        return false
      end
    end
     
    def logout
      @sessobj.thmsesslock = "DEADBEEF"
    end
    
    def login_lock?
      if @sessobj.thmsesslock != "OK"
        puts "Session doesn't exist redirecting to Login..."
        redirect '/'
      end
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
      login_lock?
      slim :dashboard
    end
    
    get '/status' do
      # Informational / Debug
      get_session_info?
    end
    
    getpost '/logout' do
      # Logout and remove thmsesslock
      if @sessobj.thmsesslock == "OK"
        logout
        redirect '/'
      end
      slim :logout
    end
    
    get '/stylesheets/screen.css' do
      send_file 'stylesheets/screen.css', :type => :css
    end
    
    get '/js/chartkick.js' do
      send_file 'js/chartkick.js', :type => :js
    end

    get '/js/jquery.min.js' do
      send_file 'js/jquery.min.js', :type => :js
    end

    get '/js/JSXTransformer.js' do
      send_file 'js/JSXTransformer.js', :type => :js
    end

    get '/js/marked.min.js' do
      send_file 'js/marked.min.js', :type => :js
    end

    get '/js/react.js' do
      send_file 'js/react.js', :type => :js
    end

    get '/js/files/authenticate.jsx' do
      send_file 'js/files/authenticate.jsx', :type => :js
    end
        
    run!
    
  end
  
end

# Start Dashboard Release

Deedrah.new
