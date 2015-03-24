require 'spec_helper'

describe Rquest do
  it 'has a version number' do
    expect(Rquest::VERSION).not_to be nil
  end

	let(:hash_params) { { moo: :to_the_max } }

  it 'it should deliver a new requestor' do
		expect(Rquest.respond_to?(:new)).to be true
		rquest = Rquest.new({uri: "http://thechive.com"})
		expect(rquest.class).to be Rquest::Requestor
  end
end

describe Hash do
	it "Should have a q_params helper method that returns a q_param friendly string" do
		h = {q: "testing", token: "testing"}
		expect( h.respond_to?(:to_q_param_string) ).to be true
		expect( h.to_q_param_string ).to eq "q=testing&token=testing"
	end

	it "Should have a to_cookie_string method" do
		h = {"Some-Cookie" => "Some Value", "_another_cookie" => "Blah"}
		expect( h.respond_to?(:to_cookie_string) ).to be true
		expect( h.to_cookie_string ).to eq "Some-Cookie=Some Value; _another_cookie=Blah;"
	end
end

describe String do
	it "Should have a q_params helper method that returns a friendly hash" do
		s = "b=1&c=2"
		expect( s.respond_to?( :to_q_param_hash ) ).to be true
		h = s.to_q_param_hash
		expect( h[:b] ).to eq "1"
		expect( h[:c] ).to eq "2"
	end

	it "Should have to_cookies_hash" do
		s = "Some-Cookie=Some Value; _another_cookie=Blah;"
		expect( s.respond_to?( :to_cookies_hash ) ).to be true
		h = s.to_cookies_hash
		test_h = {"Some-Cookie" => "Some Value", "_another_cookie" => "Blah"}
		expect( h ).to eq test_h
	end
end

describe "Rquest helper class methods" do
	describe "client_class_for_verb" do
		it "Should exist as a helper method" do
			expect( Rquest.respond_to?(:client_class_for_verb) ).to be true
		end
		it "Should return a proper class for get" do
			expect( Rquest::client_class_for_verb(:get) ).to eq Net::HTTP::Get
		end
		it "Should return a proper class for post" do
			expect( Rquest::client_class_for_verb(:post) ).to eq Net::HTTP::Post
		end
		it "Should return a proper class for put" do
			expect( Rquest::client_class_for_verb(:put) ).to eq Net::HTTP::Put
		end
		it "Should return a proper class for patch" do
			expect( Rquest::client_class_for_verb(:patch) ).to eq Net::HTTP::Patch
		end
		it "Should return a proper class for delete" do
			expect( Rquest::client_class_for_verb(:delete) ).to eq Net::HTTP::Delete
		end
		it "Should return a proper class for head" do
			expect( Rquest::client_class_for_verb(:head) ).to eq Net::HTTP::Head
		end
		it "Should return a proper class for options" do
			expect( Rquest::client_class_for_verb(:options) ).to eq Net::HTTP::Options
		end
	end
end
