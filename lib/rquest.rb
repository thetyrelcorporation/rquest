require "rquest/version"
require 'net/http/post/multipart'
require 'mimemagic'
require 'benchmark'
require "rquest/core_overrides"
require "rquest/requestor"
require 'json'

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
