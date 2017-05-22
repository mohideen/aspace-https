require 'net/http'
require 'openssl'
class Net::HTTP

  singleton_class.send(:alias_method, :start_orig, :start)

  class << self 
    def start(address, *arg, &block)
      opt = Hash.try_convert(arg[-1]) ? arg.pop : {} 
      opt[:use_ssl] = ( [ 443, 8443 ].include?(arg.first) )
      opt[:ssl_version] = :TLSv1_2
      pem_file = File.read(AppConfig[:client_cert_location])
      opt[:cert] = OpenSSL::X509::Certificate.new(pem_file)
      opt[:key] = OpenSSL::PKey::RSA.new(pem_file)
      arg << opt 
      start_orig(address, *arg, &block )
    end
  end

end
