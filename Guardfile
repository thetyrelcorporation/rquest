guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

	# watch /lib/ files
	watch(%r{^lib/(.+).rb$}) do |m|
		"spec/#{m[1]}_spec.rb"
	end

	watch(%r{^lib/rquest/(.+).rb$}) do |m|
		"spec/#{m[1]}_spec.rb"
	end

	# watch /spec/ files
	watch(%r{^spec/(.+).rb$}) do |m|
		"spec/#{m[1]}.rb"
	end
end
