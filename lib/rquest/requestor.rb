module Rquest
	class Requestor
		attr_reader :last_response, :last_response_time, :transactions
		def initialize( settings={} )
			@transactions = []
			update( settings )
		end

		def update( settings={} )
			@settings ||= {}
			@settings = @settings.merge( settings )
			@settings[:form_type] ||= :http
			apply_default_settings
			merge_settings
			@verb = @settings[:verb].to_sym 
			merge_string_and_hash_params
			@uri = URI::parse( @settings[:uri] )
			@headers = @settings[:headers]
			initialize_http_client
			set_body
			set_headers
		end

		def apply_default_settings
			@settings[:verb] ||= :get
			@settings[:q_params] ||= {}
			@settings[:cookies] ||= {}
			@settings[:headers] ||= {}
			@settings[:cookies] ||= {}
			@settings[:headers]["User-Agent"] ||= "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36"
			@settings[:payload] ||= {}
			@headers ||= {}
			@cookies ||= {}
			@q_params ||= {}
			@files = {}
			setup_files unless @settings[:files].nil?
		end

		def merge_settings
			@headers = @headers.merge( @settings[:headers] )
			@cookies = @cookies.merge( @settings[:cookies] )
			@q_params = @q_params.merge( @settings[:q_params] )
			@payload = @settings[:payload] unless @settings[:payload].nil?
		end

		def send
			@last_response_time = Benchmark.realtime do
				@last_response = @http_client.request(@http_request_client)
			end
			@transactions.push( { request: @http_request_client, response: @last_response, response_time: @last_response_time } )
			unless @last_response["Set-Cookie"].nil?
				new_cookies = @last_response["Set-Cookie"].to_cookies_hash
				@cookies = @cookies.merge( new_cookies )
			end
			case @last_response
				when Net::HTTPSuccess
					@last_response.body
				when Net::HTTPUnauthorized
					{'error' => "#{@last_response.message}: username and password set and correct?"}
				when Net::HTTPServerError
					{'error' => "#{@last_response.message}: try again later?"}
				else
					{'error' => @last_response.message}
			end
		end

		def uri_path
			uri = [(@uri.path.empty? ? "/" : @uri.path)]
			url, params = @settings[:uri].split("?")
			uri.push params if params
			uri.join("?")
		end

		def setup_files
			old_files = @settings.delete(:files)
			new_files = {}
			old_files.each do |field_name, file|
				extname = File.extname(file)
				mime_type = (extname == "") ? "text/plain" : MimeMagic.by_extension(extname).type
				new_files[field_name] = UploadIO.new( file, mime_type, File.basename(file) )
			end
			@files = new_files
		end

		def merge_string_and_hash_params
			url, string_params = @settings[:uri].split("?")
			string_params ||= ""
			hash_of_string_params = string_params.to_q_param_hash
			final_params_hash = hash_of_string_params.merge( @q_params )
			@q_params = final_params_hash
			@settings[:uri] = [url, final_params_hash.to_q_param_string].join("?")
		end

		def q_params
			q = @uri.query
			q ||= ""
			q.to_q_param_hash
		end

		def initialize_http_client
			@http_client = Net::HTTP.new( @uri.host, @uri.port )
			@http_client.use_ssl = true if @uri.scheme == "https"
		end

		def set_headers
			set_cookies if @cookies.any?
			@headers.each do |key, value|
				@http_request_client[key.to_s] = value.to_s
			end
		end

		def set_cookies
			@http_request_client["Cookie"] = @cookies.to_cookie_string
		end

		def set_body
			unless @files.any?
				klass = Rquest::client_class_for_verb( @verb )
				@http_request_client = klass.send(:new, uri_path)
				if @settings[:form_type] == :http
					@http_request_client.set_form_data( @settings[:payload] )
				elsif @settings[:form_type] == :json
					@http_request_client.body = @settings[:payload].to_json
				end
			else
				klass = Rquest::client_class_for_verb( @verb, true )
				multi_part_params = @settings[:payload].merge( @files )
				@http_request_client = klass.send(:new, @uri.path, multi_part_params)
			end
		end
	end
end
