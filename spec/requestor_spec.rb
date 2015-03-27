require 'spec_helper'

class Rquest::Requestor
	attr_accessor :uri, :verb, :headers, :http_client, :http_request_client, :body, :settings, :cookies, :files
end

describe Rquest::Requestor do
	let(:basic_settings) {
		{
			uri: "http://thechive.com",
			verb: :get
		} 
	}

	let(:basic_requestor) {
		Rquest::new( basic_settings )
	}

	let(:compex_uri_settings) {
		{
			uri: "https://google.com?q=thing",
			verb: :get,
			q_params: {
				token: "somecazystring"
			}
		}
	}

	let(:fire_fox_agent) {"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36"}

	describe "It should initialize from settings correctly" do

		it "Should set verb from settings" do
			expect( basic_requestor.verb ).to eq :get
		end

		it "Should parse settings as string correctly" do
			expect( basic_settings[:uri].class ).to be String
			expect( basic_requestor.respond_to?(:uri) ).to be true
			expect( basic_requestor.uri.class ).to eq URI::HTTP
			expect( basic_requestor.uri.host ).to eq "thechive.com"
			expect( basic_requestor.uri.scheme ).to eq "http"
			expect( basic_requestor.uri.query ).to eq ""
		end

		let(:ssl_settings) {
			{
				uri: "https://google.com",
				verb: :get
			}
		}
		it "Should parse settings as SSL correctly" do
			ssl_req = Rquest::new( ssl_settings )
			expect( ssl_req.uri.scheme ).to eq "https"
			expect( ssl_req.uri.port ).to eq 443
		end

		it "Should respond with q_params and provide a hash of query params" do
			query_settings = basic_settings
			query_settings[:uri] += "?test=testing"
			q_req = Rquest::new( query_settings )
			expect( q_req.respond_to?(:q_params) ).to be true
			expect( q_req.q_params[:test] ).to eq "testing"
		end

		it "Q params should persist for across requests" do
			query_settings = basic_settings
			query_settings[:uri] += "?test=testing"
			q_req = Rquest::new( query_settings )
			expect( q_req.respond_to?(:q_params) ).to be true
			expect( q_req.q_params[:test] ).to eq "testing"
			new_uri = query_settings[:uri].split("?").first
			q_req.update({uri: new_uri})
			expect( q_req.q_params[:test] ).to eq "testing"
		end

		it "Should merge q params from uri and additional q_params in settings into q params instance variable" do
			req = Rquest::Requestor::new( compex_uri_settings )
			q_params = req.q_params
			expect( q_params[:q] ).to eq "thing"
			expect( q_params[:token] ).to eq "somecazystring"
		end

		it "Should initialize headers correctly" do
			settings = compex_uri_settings
			settings[:headers] = {
				"User-Agent" => fire_fox_agent
			}
			req = Rquest::Requestor::new(settings)
			expect( req.respond_to?(:headers) ).to be true
			expect( req.headers["User-Agent"] ).to eq fire_fox_agent
		end
	end

	describe "HTTP Client" do
		it "Should setup an http client based on URI and other settings" do
			expect( basic_requestor.http_client.class ).to be Net::HTTP
		end

		it "Should automatically apply ssl for https clients" do
			req = Rquest::Requestor::new( compex_uri_settings )
			expect( req.http_client.use_ssl? ).to be true
		end
	end

	describe "HTTP Request Client" do
		it "Should setup an http request client based on verb setting" do
			expect( basic_requestor.http_request_client.class).to eq Net::HTTP::Get
		end

		it "Should have settings headers set on itself" do
			settings = compex_uri_settings
			settings[:headers] = {
				"User-Agent" => fire_fox_agent
			}
			req = Rquest::Requestor::new(settings)
			expect(req.http_request_client["User-Agent"]).to eq fire_fox_agent
		end
	end

	describe "Request Path" do
		it "Should respond with the path from the uri" do
			settings = basic_settings
			settings[:uri] = "http://thechive.com/some/place"
			req = Rquest::Requestor::new( settings )
			expect( req.uri_path ).to eq "/some/place"
		end

		it "Should fill in / for a blank path" do
			expect(basic_requestor.uri_path).to eq "/"
		end
	end

	describe "Payload" do
		it "Should apply the settings payload to the body of the request in a & = form" do
			settings = compex_uri_settings
			settings[:headers] = {
				"User-Agent" => fire_fox_agent
			}
			settings[:payload] = {
				form_field_1: "testing",
				form_field_2: "onetwothree"
			}
			req = Rquest::Requestor::new( settings )
			expect( req.respond_to?(:body) ).to be true
			expect( req.http_request_client.body ).to eq "form_field_1=testing&form_field_2=onetwothree"
		end

		let(:a_file) {
			File.open("#{Dir.pwd}/Gemfile")
		}

		it "Should parse files and setup for multipart form data" do
			settings = {uri: "http://localhost:3000/upload"}
			settings[:verb] = :post
			settings[:headers] = {
				"User-Agent" => fire_fox_agent
			}
			settings[:payload] = {
				form_field_1: "testing",
				form_field_2: "onetwothree"
			}
			settings[:files] = {
				da_file_field: a_file
			}
			rquest = Rquest::Requestor::new( settings )

			file = rquest.files.first
			expect( file.first ).to eq :da_file_field
			expect( file.last.content_type ).to eq "text/plain"
		end

		it "Should setup mime types automatically" do
			settings = {uri: "http://localhost:3000/upload"}
			settings[:verb] = :post
			settings[:headers] = {
				"User-Agent" => fire_fox_agent
			}
			settings[:payload] = {
				form_field_1: "testing",
				form_field_2: "onetwothree"
			}
			settings[:files] = {
				da_file_field: a_file
			}
			rquest = Rquest::Requestor::new( settings )

			file = rquest.files.first
			expect( file.first ).to eq :da_file_field
			expect( file.last.content_type ).to eq "text/plain"
		end

		it "Should handle multipart files automatically" do
			settings = {uri: "http://localhost:3000/upload"}
			settings[:verb] = :post
			settings[:headers] = {
				"User-Agent" => fire_fox_agent
			}
			settings[:payload] = {
				form_field_1: "testing",
				form_field_2: "onetwothree"
			}
			the_file = File.open("#{Dir.pwd}/spec/test_files/test_tiger.jpg")
			settings[:files] = {
				da_file_field: the_file
			}
			rquest = Rquest::Requestor::new( settings )
			expect(rquest.http_request_client["User-Agent"]).to eq fire_fox_agent

			file = rquest.files.first
			expect( file.first ).to eq :da_file_field
			expect( file.last.content_type ).to eq "image/jpeg"
		end
	end

	describe "Send" do
		it "Should have a send method" do
			expect( basic_requestor.respond_to?(:send) ).to be true
		end

		it "Should respond with request boedy" do
			res = basic_requestor.send
			expect( res.class ).to be String
		end

		it "Should stash the whole response and allow read" do
			basic_requestor.send
			expect( basic_requestor.last_response.class ).to be Net::HTTPOK
		end

		it "Should store request time" do
			basic_requestor.send
			expect( basic_requestor.respond_to?(:last_response_time) ).to be true
			expect( basic_requestor.last_response_time.class ).to be Float
		end
	end


	describe "Sessions" do
		let(:session_settings) {
			{
				verb: :get,
				uri: "https://marijuana-jobs.us"
			}
		}
		let(:session_rquest) {
			Rquest::new(session_settings)
		}

		it "Should have reasonable default headers for healthy automatic sessions" do
			expect(session_rquest.http_request_client["User-Agent"]).to eq fire_fox_agent
			expect(session_rquest.http_request_client["Accept"]).to eq "*/*"
		end

		describe "Cookies" do
			it "Should initialize headers with cookies settings" do
				settings = session_settings
				settings[:cookies] = {
					"Some-Cookie" => "Some Value",
					"Foo" => "Bar"
				}
				rquest = Rquest::new(settings)
				expect( rquest.cookies ).to eq settings[:cookies]
				expect( rquest.http_request_client["Cookie"] ).to eq "Some-Cookie=Some Value; Foo=Bar;"
			end

			it "Should update cookies after each request" do
				rquest = Rquest::new( {verb: :get, uri: "https://marijuana-jobs.us"} )
				rquest.send
				expect( rquest.cookies["_marijuana_jobs_session"].nil? ).to be false
			end
		end
	end

	describe "Requests" do
		it "Should preform a proper get request" do
			rquest = Rquest::new({verb: :get, uri: "http://thechive.com"})
			body = rquest.send
			expect(body.scan("theCHIVE - Funny Photos and Funny Videos - Keep Calm and Chive On").any?).to be true
		end

		it "Should preform a proper get request with q params" do
			q = "testing"
			rquest = Rquest::new({verb: :get, uri: "https://www.google.com?q=#{q}"})
			body = rquest.send
			expect( body.scan(/#{q}/i).any? ).to be true
		end
	end

end
