class Hash
	def to_q_param_string
		self.inject([]){|r,(k,v)| r.push( "#{k}=#{v}" )}.join("&")
	end

	def to_cookie_string
		self.inject([]){|r,(k,v)| r.push( "#{k}=#{v}" )}.join("; ") + ";"
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
	def to_cookies_hash
		tmp = self[0..-2]
		tmp.split("; ").inject({}) do |hash, key_value|
			key, value = key_value.split("=")
			hash[key] = value
			hash
		end
	end
end
