########################################################################
#
# Author: Brian Hood
# Email: <brianh6854@googlemail.com>
# Description: Threatmonitor User Administration
# 
# Extends the functionality of the Thm module adding Authorization
# Adding User / Group Privileges functionality
#
########################################################################

require "#{File.dirname(__FILE__)}/thm-authorization.rb"

module Thm::Authorization

  class Privileges < AuthTemplate

      puts "\e[1;34m\ Manage User / Group Privileges \e[0m\ \n\n"
      
      def mkhash(payload)
        hash = Digest::SHA512.new
        puts "Password Omitted !"
        hash.update("#{payload}")
      end

      def user_exists?(name)
        objbuilder("#{name}", "userexists?", msg=false)
      end
      
      def add_user
        while buf = Readline.readline("\e[1;36m\Add User: \e[0m\ ", true)
          @thmusername = buf
          while buf2 = Readline.readline("\e[1;36m\Existing Group: \e[0m\ ", true)
            @thmgroupname = buf2
            break
          end
          if self.user_exists?("#{@thmusername}"); puts "Exiting ... Can't create duplicate users ?"; exit; end 
          break                
        end
      end
      
      #def update_user; end
      
      #alias_method :modify_user, :update_user
      
      def delete_user
        while buf = Readline.readline("\e[1;36m\Remove User: \e[0m\ ", true)
          @thmusername = buf
          objbuilder("#{@thmusername}", "deleteuser")
          break                
        end      
      end
      
      def set_password(prompt="\e[1;36m\Password: \e[0m\ ")
        print prompt
        plain = STDIN.noecho(&:gets).chomp
        @thmpassword = mkhash(plain)
        objbuilder("#{@thmusername}", "adduser", "#{@thmgroupname}", "#{@thmpassword}")
      end
      
      def list_users
        objbuilder("system", "listusers")
      end

      def list_groups
        objbuilder("system", "listgroups")
      end
            
      def group_exists?(name)
        objbuilder("#{name}", "groupexists?")
      end
      
      def add_group
        while buf = Readline.readline("\e[1;36m\Add Group: \e[0m\ ", true)
          @thmgroupname = buf
          if self.group_exists?("#{@thmgroupname}") == true
            puts "Exiting Group exists ..."
          end
          if self.group_exists?("#{@thmgroupname}"); puts "Exiting ... Can't create duplicate groups ?"; exit; end
          objbuilder("#{@thmgroupname}", "addgroup")
          break                
        end  
      end
      
      def delete_group
        while buf = Readline.readline("\e[1;36m\Delete Group: \e[0m\ ", true)
          @thmgroupname = buf
          objbuilder("#{@thmgroupname}", "deletegroup")
          break                
        end  
      end
    
  end
  
end


