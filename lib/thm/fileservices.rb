
module Thm

  class FileServices
      
    def initialize
      @fdata = String.new
    end
    
    def conf_loader(file="config.rb")
      if !File.exists?("#{Dir.home}/.thm/#{file}")
        File.open("#{Dir.home}/.thm/#{file}", 'w') {|n|
          n.write(@fdata)
        }
      else
        require Dir.home+"/.thm/config.rb"      
      end
    end

    def thmhome?(file="config.rb")
      file ||= file
      if !Dir.exists?("#{Dir.home}/.thm")
        Dir.mkdir("#{Dir.home}/.thm")
        puts "Creating .thm home subfolder"
        File.open(File.expand_path(File.join(File.dirname(__FILE__), "../#{file}")), 'r') {|n|
          n.each_line {|l|
            @fdata << l
          }
        }
      end
      begin
        conf_loader("#{file}")
      rescue
        puts "Error loading config from home directory"
      end
    end

  end
  
end
