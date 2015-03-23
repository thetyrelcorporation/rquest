module Rquest
	class Requestor
		attr_reader :response, :response_time
		def initialize( settings={} )
			@settings = settings
			apply_default_settings
			@verb = settings[:verb].to_sym
			merge_string_and_hash_params
			@uri = URI::parse( @settings[:uri] )
			@headers = @settings[:headers]
			initialize_http_client
			set_headers
			set_body
		end

		def send
			@response_time = Benchmark.realtime do
				@response = @http_client.request(@http_request_client)
			end
			@response.body
		end

		def uri_path
			@uri.path.empty? ? "/" : @uri.path
		end

		def apply_default_settings
			@settings[:verb] ||= :get
			@settings[:q_params] ||= {}
			@settings[:headers] ||= {}
			@settings[:payload] ||= {}
			setup_files unless @settings[:files].nil?
		end

		def setup_files
			old_files = @settings.delete(:files)
			new_files = {}
			old_files.each do |field_name, file|
				extname = File.extname(file)
				mime_type = (extname == "") ? "text/plain" : MimeMagic.by_extension(extname).type
				new_files[field_name] = UploadIO.new( file, mime_type, File.basename(file) )
			end
			@settings[:files] = new_files
		end

		def merge_string_and_hash_params
			url, string_params = @settings[:uri].split("?")
			string_params ||= ""
			hash_of_string_params = string_params.to_q_param_hash
			final_params_hash = hash_of_string_params.merge( @settings[:q_params] )
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
			klass = Rquest::client_class_for_verb( @verb )
			@http_request_client = klass.send(:new, uri_path)
		end

		def set_headers
			@headers.each do |key, value|
				@http_request_client[key.to_s] = value.to_s
			end
		end

		def set_body
			if @settings[:files].nil?
				@http_request_client.set_form_data( @settings[:payload] )
			else
				klass = Rquest::client_class_for_verb( @verb, true )
				multi_part_params = @settings[:payload].merge( @settings[:files] )
				@http_request_client = klass.send(:new, @uri.path, multi_part_params)
			end
		end
	end
end
