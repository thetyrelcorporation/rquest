require "rquest/version"
require 'net/http/post/multipart'
require 'mimemagic'
require 'benchmark'
require "rquest/requestor"

module Rquest
	class << self
		def new( settings )
			Requestor.new( settings )
		end

		def client_class_for_verb( verb, use_multipart=false )
			v = verb.to_s.capitalize
			unless use_multipart
				Object.const_get("Net::HTTP::#{v}")
			else
				Object.const_get("Net::HTTP::#{v}::Multipart")
			end
		end
	end
end

class Hash
	def to_q_param_string
		self.inject([]){|r,(k,v)| r.push( "#{k}=#{v}" )}.join("&")
	end
end

class String
	def to_q_param_hash
		self.split("&").inject({}) do |hash, key_value|
			key, value = key_value.split("=")
			hash[key.to_sym] = value
			hash
		end
	end
end
