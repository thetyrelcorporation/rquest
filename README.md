# Rquest

A helper library to easily define restful web requests in ruby.

Bassically I am tiered of constantly relooking up NET HTTP blog post to try and remember how to say override the default headers or attatch a file as a multipart post request. Also there are things about the ruby request generation process I felt I could improve such as, autodetecting the need for ssl from the URI and providing a clean DSL for request definition. As well as cleaner file attatchment.

RQuest makes it easy to build request and gives you full control over every aspect of the request. I modeled it after the chrome extension postman. Everything you can do with postman you can do with RQuest and it follows the same intuitive work flow.

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
rquest = RQuest.new({verb: :get, uri: "https://google.com"})
response_body = rquest.send
response_time = rquest.response_time
full_request_object = rquest.response
```

You can easily combine query params with the uri and the settings hash

```ruby
rquest = RQuest.new({verb: :get, uri: "https://google.com?q=testing", q_params: {token: "foo"}})
```

This will result in a request with a URI of http://google.com?q=testing&token=foo behind the sceens

## Auto SSL
Any uri with https will set use_ssl on the request object automatically. No more.

```ruby
https.use_ssl = true
```

## Form data POST/PUT/PATCH/DELETE/OPTIONS Requests

```ruby
rquest = RQuest.new({verb: :get, uri: "https://google.com", headers: {"User-Agent" => "A Freaking Spaceship"} })
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
