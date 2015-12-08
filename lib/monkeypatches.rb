########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Dashboard
#
# Slight patch here in the =begin =end section
#
########################################################################

class MonetDBConnection

  # perform a real connection; retrieve challenge, proxy through merovinginan, build challenge and set the timezone
  def real_connect
    
    server_challenge = retrieve_server_challenge()
    if server_challenge != nil
      salt = server_challenge.split(':')[0]
      @server_name = server_challenge.split(':')[1]
      @protocol = server_challenge.split(':')[2].to_i
      @supported_auth_types = server_challenge.split(':')[3].split(',')
      @server_endianness = server_challenge.split(':')[4]
=begin 
Causes issues with Threatmonitor
      #if @@SUPPORTED_PROTOCOLS.include?(@protocol) == False
      #  raise MonetDBProtocolError, "Protocol not supported. The current implementation of ruby-monetdb works with MAPI protocols #{@@SUPPORTED_PROTOCOLS} only."
      #end
=end
      @pwhash = server_challenge.split(':')[5]
    else
      raise MonetDBConnectionError, "Error: server returned an empty challenge string."
    end
    
    # The server supports only RIPMED160 or crypt as an authentication hash function, but the driver does not.
    if @supported_auth_types.length == 1
      auth = @supported_auth_types[0]
      if auth.upcase == "RIPEMD160"
        raise MonetDBConnectionError, auth.upcase + " " + ": algorithm not supported by ruby-monetdb."
      end
    end

    reply = build_auth_string_v9(@auth_type, salt, @database)

    if @socket != nil
      @connection_established = true

      send(reply)
      monetdb_auth = receive
      
      if monetdb_auth.length == 0
        # auth succedeed
        true
      else
        if monetdb_auth[0].chr == MSG_REDIRECT
        #redirection
          
          redirects = [] # store a list of possible redirects
          
          monetdb_auth.split('\n').each do |m|
            # strip the trailing ^mapi:
            # if the redirect string start with something != "^mapi:" or is empty, the redirect is invalid and shall not be included.
            if m[0..5] == "^mapi:"
              redir = m[6..m.length]
              # url parse redir
              redirects.push(redir)  
            else
              $stderr.print "Warning: Invalid Redirect #{m}"
            end          
          end
          
          if redirects.size == 0  
            raise MonetDBConnectionError, "No valid redirect received"
          else
            begin 
              uri = URI.split(redirects[0])
              # Splits the string on following parts and returns array with result:
              #
              #  * Scheme
              #  * Userinfo
              #  * Host
              #  * Port
              #  * Registry
              #  * Path
              #  * Opaque
              #  * Query
              #  * Fragment
              server_name = uri[0]
              host   = uri[2]
              port   = uri[3]
              database   = uri[5].gsub(/^\//, '') if uri[5] != nil
            rescue URI::InvalidURIError
              raise MonetDBConnectionError, "Invalid redirect: #{redirects[0]}"
            end
          end
          
          if server_name == MONETDB_MEROVINGIAN
            if @auth_iteration <= MEROVINGIAN_MAX_ITERATIONS
              @auth_iteration += 1
              real_connect
            else
              raise MonetDBConnectionError, "Merovingian: too many iterations while proxying."
            end
          elsif server_name == MONETDB_MSERVER
            begin
              @socket.close
            rescue
              raise MonetDBConnectionError, "I/O error while closing connection to #{@socket}"
            end
            # reinitialize a connection
            @host = host
	          @port = port
            
            connect(database, @auth_type)
          else
            @connection_established = false
            raise MonetDBConnectionError, monetdb_auth
          end
        elsif monetdb_auth[0].chr == MSG_INFO
          raise MonetDBConnectionError, monetdb_auth
        end
      end
    end
  end

end