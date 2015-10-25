# Rquest

A helper library to easily define restful web requests in ruby.

Bassically I am tiered of constantly relooking up NET HTTP blog post to try and remember how to say override the default headers or attatch a file as a multipart post request. Also there are things about the ruby request generation process I felt I could improve such as, autodetecting the need for ssl from the URI and providing a clean DSL for request definition, as well as cleaner file attatchment.

Rquest makes it easy to build request and gives you full control over every aspect of the request. I modeled it after the chrome extension postman. Everything you can do with postman you can do with Rquest and it follows the same intuitive work flow.

In addition Rquest is an object that can handle a full session request cycle. You can say log in have the authentication cookies set by the server and then proceed to parse your dashboard.

## Credit where credit is due
- Special thanks to nicksieger for the multipart-post gem.
- Special thanks to minad for the mimemagic gem.
- Both of these were crucial in creating the easy file upload feature.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rquest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rquest

## Simple GET Request

Its basic setup involves setting the uri and action. Its send method will execute the rquest and return the body. You can access the full request object and the response time if you need them.

```ruby
rquest = Rquest.new({verb: :get, uri: "https://google.com"})
response_body = rquest.send
response_time = rquest.last_response_time
response_object = rquest.last_response
```

You can easily combine query params with the uri and the settings hash

```ruby
rquest = Rquest.new({verb: :get, uri: "https://google.com?q=testing", q_params: {token: "foo"}})
```

This will result in a request with a URI of http://google.com?q=testing&token=foo behind the sceens

## Auto SSL
Any uri with https will set use_ssl on the request object automatically. No more.

```ruby
https.use_ssl = true
```

## Form data POST/PUT/PATCH/DELETE/OPTIONS Requests

All controlled from the same settings hash with the payload key

```ruby
rquest = Rquest.new({verb: :post, uri: "https://google.com", payload: {a_field: "stuff", another_field: "more stuff"} })
rquest.send
```

The default body style is key=value&other_key=other_value however you can set it to a json body if you need like so

```ruby
rquest = Rquest.new({verb: :post, uri: "https://google.com", payload: {a_field: "stuff", another_field: "more stuff"}, form_type: :json })
rquest.send
```

Alright the best part for last

## Auto multipart forum

Just pass file objects into the files key and everything will be handled for you. It will automatically switch to multipart and detect mime types!

```ruby
f1 = File.open("path/to/file.txt")
f2 = File.open("path/to/file.jpg")
rquest = Rquest.new({verb: :get, uri: "https://google.com", payload: {a_field: "stuff", another_field: "more stuff"}, files: {file_field_1: f1, file_field_2: f2} })
rquest.send
```

## Sessions

Rquest is built to behave like a fresh incognito browser. Every time you apply send it will add the response to the transactions attribute and set the last_response and last_response_time.

Simply call update to change what you need before the next send like so. New settings will be merged so they will either override old ones ore creat new ones. Any non specified setting will remain untouched from the last request.

```ruby
rquest = Rquest.new({verb: :get, uri: "https://google.com?q=testing", q_params: {token: "foo"}})
rquest.send
rquest.update({q_params: {q: "other search value"}}
rquest.send
first_query = rquest.transactions.first
last_query = rquest.transactions.last
```

Transactions are stored as has with their request, response and response time available for future reference. Continuing from above we could.

```ruby
old_request = first_query[:request]
old_response = first_query[:response]
time_it_took = first_query[:response_time]
```

## Cookies

You can set cookies for a request by adding them to the settings[:cookies] like

```ruby
rquest = Rquest.new({verb: :get, uri: "https://google.com", payload: {a_field: "stuff", another_field: "more stuff"}, cookies: {"MySpecialCookie" => "SomeSuperSecretValue"} })
```

Any response will add/merge any cookies in the "Set-Cookie" header of the response to your next request

```ruby
rquest = Rquest.new({verb: :post, uri: "https://somesite.com/sessions", payload: {username: "foobar", password: "SuperSecret"}})
rquest.send
```
If this authenticates correctly then the server will send the right Set-Cookie so then you can do something like.

```ruby
rquest.update({uri: "https://somesite.com/mydashboard"}
rquest.send
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rquest/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
