require 'net/http'
require 'openssl'

module Net

  class HTTP

    singleton_class.send(:alias_method, :start_orig, :start)

    class << self
      def start(address, *arg, &block)
        opt = Hash.try_convert(arg[-1]) ? arg.pop : {}
        opt[:use_ssl] = ( [ 443, 8443 ].include?(arg.first) )
        if AppConfig[:client_cert_location]
          pem_file = File.read(AppConfig[:client_cert_location])
          opt[:cert] = OpenSSL::X509::Certificate.new(pem_file)
          opt[:key] = OpenSSL::PKey::RSA.new(pem_file)
        end
        arg << opt
        start_orig(address, *arg, &block )
      end
    end

  end

  class HTTPGenericRequest
    def send_request_with_body_stream(sock, ver, path, f)
      unless content_length() or chunked?
        raise ArgumentError,
            "Content-Length not given and Transfer-Encoding is not `chunked'"
      end
      supply_default_content_type
      write_header sock, ver, path
      wait_for_continue sock, ver if sock.continue_timeout
      if chunked?
        chunker = Chunker.new(sock)
        IO.copy_stream(f, chunker)
        chunker.finish
      else
        # copy_stream can sendfile() to sock.io unless we use SSL.
        # If sock.io is an SSLSocket, copy_stream will hit SSL_write()
        if  sock.io.is_a? OpenSSL::SSL::SSLSocket
          IO.copy_stream(f, sock.io, 16 * 1024 * 1024) until f.eof?
        else
          IO.copy_stream(f, sock.io)
        end
      end
    end
  end
end
