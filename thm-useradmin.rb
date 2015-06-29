########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor User Administration
# 
# The use of Singletons is mainly for Data Security 
#
########################################################################

require 'getoptlong'
require 'readline'
require 'digest'
require './thmmq.rb'
require 'io/console'

module Thm::Privileges

  module Datastore
    obj2 = Thm::Localmachine.new
    obj2.datastore = "monetdb"
    obj2.dbconnect
  end
  
  class Users
    
    include Datastore
    
    class << self
    
      puts "\e[1;33m\Threatmonitor - User Administration\e[0m\ "
      puts "\e[1;33m\===================================\e[0m\ \n\n"
      
      puts "\e[1;31m\ Create User \e[0m\ \n\n"
      
      def mkhash(payload)
        hash = Digest::SHA512.new
        hash.update("#{payload}")
        puts "Password Omitted !"
      end

      def add_user
        while buf = Readline.readline("\e[1;36m\Username: \e[0m\ ", true)
          username = buf
          break                
        end
      end
      
      def get_password(prompt="\e[1;36m\Password: \e[0m\ ")
        print prompt
        plain = STDIN.noecho(&:gets).chomp
        password = mkhash(plain)
      end

    end

  end
  
  class Groups
  
    include Datastore
    
    class << self
    
      def group_exist?(name)

        if val == 0
          false
        else
          true
        end
      end
      
      def create_group(name)
      
      end
      alias_method :remove_group, :create_group
    end
    
  end
  
end

obj = Thm::Privileges
obj::Users::add_user
obj::Users::get_password



