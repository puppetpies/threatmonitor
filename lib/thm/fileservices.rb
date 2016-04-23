########################################################################
#
# Author: Brian Hood
# Email: <brianh6854@googlemail.com>
# Description: Libraries
#
#   File services for local / global settings
#
########################################################################

module Thm

  class FileServices
      
    def initialize
      @fdata = String.new
    end
    
    def conf_loader(file="config.rb", loadswitch=true)
      file ||= file
      if !File.exists?("#{Dir.home}/.thm/#{file}")
        File.open("#{Dir.home}/.thm/#{file}", 'w') {|n|
          n.write(@fdata)
        }
      end
      begin
        if loadswitch == true # So original backup config doesn't change your settings
          require "#{Dir.home}/.thm/#{file}"
        end
      rescue
        raise Exception, "Failed to load something went wrong check permissions !"
      end
    end

    def thmhome?(file="config.rb")
      file ||= file
      if Dir.exists?("#{Dir.home}/.thm") == false
        Dir.mkdir("#{Dir.home}/.thm")
        puts "Creating .thm home subfolder copying config.rb"
        File.open(File.expand_path(File.join(File.dirname(__FILE__), "../../#{file}")), 'r') {|n|
          n.each_line {|l|
            @fdata << l
          }
        }
      end
      begin
        conf_loader("#{file}")
        conf_loader("config-original.rb", false)
      rescue
        raise Exception, "Error loading config from home directory"
      end
    end

  end
  
end
