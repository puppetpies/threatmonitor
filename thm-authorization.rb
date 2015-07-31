########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Authorization
# 
# Extends the functionality of the Thm module adding Authorization
#
########################################################################

require 'digest'
require "#{File.dirname(__FILE__)}/lib/thm.rb"
require 'pp'

puts "\e[1;33m\Threatmonitor - User Administration\e[0m\ "
puts "\e[1;33m\===================================\e[0m\ \n\n"      
   
module Thm::Authorization

  class AuthTemplate < Thm::DataServices
    
    def initialize
      super
      @debug = true
    end
    
    def setup_privileges(name, obj)
      data = obj.new
      actiontemplate = { 'userdata' => { 
              'type' => "#{data.type}",
              'group' => "#{data.group}",
              'password' => "#{data.password}"
            }
      }
      #pp actiontemplate
      if @debug == 1
        puts "Action template User data"
        puts "User: #{name}"
        puts "Type: #{actiontemplate["userdata"]["type"]}"
        puts "Group: #{actiontemplate["userdata"]["group"]}"
        puts "Password: #{actiontemplate["userdata"]["password"]}"
      end
      case actiontemplate["userdata"]["type"]
      when "adduser"
        sqlid = "SELECT gid FROM groups WHERE groupname = '#{actiontemplate["userdata"]["group"]}';"
        resgid = @conn.query("#{sqlid}")
        rowgid = resgid.fetch_hash
        puts "#{rowgid["gid"].to_i}"
        if rowgid["gid"] =~ /^[0-9]*$/ # Check the value is numeric       
          sqlidcnt = "SELECT count(*) as num FROM groups WHERE groupname = '#{actiontemplate["userdata"]["group"]}';"
          resgidcnt = @conn.query("#{sqlidcnt}")
          rowgidcnt = resgidcnt.fetch_hash
          puts "#{rowgidcnt["num"].to_i}"
          if rowgidcnt["num"].to_i == 1
            sql = "INSERT INTO users (username, password, gid) VALUES ('#{name}', '#{actiontemplate["userdata"]["password"]}', #{rowgid["gid"]});"
            begin
              @conn.query("#{sql}")
              @conn.commit
            rescue
              puts "There was a issue adding user check database privileges"
            end
          else
            puts "Group #{actiontemplate["userdata"]["group"]} doesn't exist"
          end
        else
          puts "Group #{actiontemplate["userdata"]["group"]} invalid GID ?"
        end
      when "userexists?"
        sqlchkname = "SELECT COUNT(*) as num FROM users WHERE username = '#{name}';"
        reschkname = @conn.query("#{sqlchkname}")
        rowchknamecnt = reschkname.fetch_hash
        puts "#{rowchknamecnt["num"].to_i}"
        if rowchknamecnt["num"].to_i == 0
          puts "User #{name} doesn't exist"
          return false
        else
          return true
        end
      when "deleteuser"
        if self.user_exists?("#{name}") == true
          sqldeluser = "DELETE FROM users WHERE username = '#{name}';"
          begin
            @conn.query("#{sqldeluser}")
            @conn.commit
            puts "User #{name} deleted"
          rescue
            puts "Error deleting User #{name}"
          end
        end
      when "listusers"
        sqllsusers = "SELECT uid, username FROM users;"
        reslsusers = @conn.query("#{sqllsusers}")
        puts "\n"
        puts "\e[1;38m|       Users Table        |\e[0m\ \n"
        puts "\e[1;38m\\==========================/\e[0m\ "
        while row = reslsusers.fetch_hash do
          puts "UID: #{row["uid"]} Username: #{row["username"]}"
        end
        puts "\n"
      when "listgroups"
        sqllsusers = "SELECT gid, groupname FROM groups;"
        reslsusers = @conn.query("#{sqllsusers}")
        puts "\n"
        puts "\e[1;38m|       Groups Table        |\e[0m\ \n"
        puts "\e[1;38m\\==========================/\e[0m\ "
        while row = reslsusers.fetch_hash do
          puts "GID: #{row["gid"]} Groupname: #{row["groupname"]}"
        end
        puts "\n"
      when "groupexists?"
        sqlchkname = "SELECT COUNT(*) as num FROM groups WHERE groupname = '#{name}';"
        reschkname = @conn.query("#{sqlchkname}")
        rowchknamecnt = reschkname.fetch_hash
        puts "#{rowchknamecnt["num"].to_i}"
        if rowchknamecnt["num"].to_i == 0
          if actiontemplate["userdata"]["msg"] == true  
            puts "Group #{name} doesn't exist"
          end
          return false
        else
          return true
        end
      when "deletegroup"
        puts "#{name}"
        if self.group_exists?("#{name}") == true
          sqldelgroup = "DELETE FROM groups WHERE groupname = '#{name}';"
          begin
            @conn.query("#{sqldelgroup}")
            @conn.commit
            puts "Group #{name} deleted"
          rescue
            puts "Error deleting Group #{name}"
          end          
        end
      when "addgroup"
        sqlidcnt = "SELECT count(*) as num FROM groups WHERE groupname = '#{name}';"
        resgidcnt = @conn.query("#{sqlidcnt}")
        rowgidcnt = resgidcnt.fetch_hash
        puts "#{rowgidcnt["num"].to_i}"
        if rowgidcnt["num"].to_i == 0
          sqladdgroup = "INSERT INTO groups (groupname) VALUES ('#{name}');"
          begin
            @conn.query("#{sqladdgroup}")
            @conn.commit
          rescue
            puts "There was a issue adding group check database privileges"
          end
        else
          puts "Group #{actiontemplate["userdata"]["group"]} doesn't exist"
        end
      end
    end
    
    # Build a class object using a Flat scope so we can pass through variables
    # Then pass it as an object to setup_privileges
    def objbuilder(user, type="", group="", password="")
    # user becomes group when adding / deleting groups
    # objbuilder("#{@thmgroupname}", "addgroup")                                                                                                      
      designobj = Class.new do
        attr_reader :type, :group, :password
          define_method :initialize do
            instance_variable_set("@type", "#{type}")
            instance_variable_set("@group", "#{group}")
            instance_variable_set("@password", "#{password}")
          end
      end
      setup_privileges("#{user}", designobj)
    end
    
  end
  
end

