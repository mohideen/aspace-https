require 'net/http'
class Net::HTTP

  singleton_class.send(:alias_method, :start_orig, :start)

  class << self 
    def start(address, *arg, &block)
      opt = Hash.try_convert(arg[-1]) ? arg.pop : {} 
      opt[:use_ssl] = ( [ 443, 8443 ].include?(arg.first) ) 
      arg << opt 
      start_orig(address, *arg, &block )
    end
  end

end
