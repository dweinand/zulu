require "celluloid/io"
require "net/http"
require "addressable/uri"

module Zulu
  module Http
    
    def self.post(url, options={})
      uri = Addressable::URI.parse(url)
      params = options.delete(:params) || {}
      Net::HTTP.post_form(uri, params)
    end
  
    def self.get(url, options={})
      uri = Addressable::URI.parse(url)
      params = options.delete(:params)
      uri.query = URI.encode_www_form(params) if params
      Net::HTTP.get_response(uri)
    end
  end
end