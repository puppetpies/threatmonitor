########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor User Administration
# 
# Extends the functionality of the Thm module adding Authorization
# Adding User / Group Privileges functionality
#
########################################################################


require 'getoptlong'
require 'readline'
require 'io/console'
require './thm-privileges.rb'

trap("INT") {
  puts "\nSee you soon !"
  exit
}

obj = Thm::Authorization::Privileges.new
obj.datastore = "monetdb"
obj.dbconnect
if obj.user_exists?("admin") == true
  # Menu
  while buf = Readline.readline("\e[1;32m\Threatmonitor>\e[0m\ ", true)
    begin
      puts "\n"
      puts "\e[1;38m|   User Administration    |\e[0m\ \n"
      puts "\e[1;38m\\==========================/\e[0m\ "
      puts "\n"
      puts "\e[1;36m1)\e[0m\ Add User"
      puts "\e[1;36m2)\e[0m\ Delete User"
      puts "\e[1;36m3)\e[0m\ Add Group"
      puts "\e[1;36m4)\e[0m\ Delete Group"
      puts "\e[1;36m5)\e[0m\ List Users"
      puts "\e[1;36m6)\e[0m\ List Groups"
      puts ""
      puts "q: Exit Threatmonitor Suite\n"
      puts "\n"
      case buf
      when "1"
        obj.add_user
      when "2"
        obj.delete_user
      when "3"
        obj.add_group
      when "4"
        obj.delete_group
      when "5"
        obj.list_users
      when "6"
        obj.list_groups
      when "q"
        puts "\nSee you soon !"
        exit
      end
    rescue NoMethodError
    end
  end  
else
  # Create admin user if none exists
  #obj.add_user
  #obj.delete_user
  #obj.set_password
end



