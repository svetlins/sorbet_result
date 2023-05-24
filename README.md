# SorbetResult

A type-safe `SorbetResult` class useful for dealing with fallible code. Designed for use with [Sorbet](https://sorbet.org/).

This is a work in progress at this point, so do not actually use.

## Installation

Not yet released on rubygems.org.

## Usage

Let's say as part of some flow in our application we interact with a remote API and that makes the flow fallible.

For example we have an API client code that looks like this:

```ruby
module SomeAPI
  extend T::Sig
  extend self

  sig { returns(SorbetResult::Result[T.untyped, T.untyped]) }
  def request
    if rand > 0.5
      return SorbetResult::Result.ok(body: 'some body')
    else
      return SorbetResult::Result.error(body: 'some error body')
    end
  end
end
```

Now, we have some intermediate service that's calling this API client and we can hook type-safe transforms that operate on the success or error variants. This way the fallibility is retained but the contents of the `Result` object are refined with some app specific logic. The type is basically refined from `Result[T.untyped, T.untyped]` to `Result[Success, Error]` where `Success` and `Error` are types that we control.

```ruby
module SomeService
  extend T::Sig
  extend self

  sig { returns(SorbetResult::Result[Parsed, LocalError])}
  def call
    SomeAPI.request
      .transform_value { |value| parse(value) }
      .transform_error { |error| parse_error(error) }
  end

  sig { params(value: T.untyped).returns(Parsed) }
  def parse(value)
    Parsed.new
  end

  sig { params(error: T.untyped).returns(LocalError) }
  def parse_error(error)
    LocalError.new
  end
end
```

On the other hand there are situations when we just want to bail out in case of error. In this case we can use `unwrap_or` + `return` from the passed block. For example:

```ruby
module SomeTopLevelCode
  extend T::Sig
  extend self

  sig { void }
  def action
    result = SomeService.call.unwrap_or { |error| return render_error(error) }

    render(result)
  end

  sig { params(error: LocalError).void }
  def render_error(error)
    # ...
  end

  sig { params(value: SomeService::Parsed).void }
  def render(value)
    # ...
  end
end
```

Note what gets enforced in the previes code block:

1. `result` is always the success type. If the underlying fallible operation had failed, we would have already returned from the block above.

```ruby
result = SomeService.call.unwrap_or { |error| return render_error(error) }

T.reveal_type(result) # <- Revealed type: SomeService::Parsed
```

2. It's impossible to "forget" to return from the block above, as the block passed to `unwrap_or` is required to return the success type OR return.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/svetlins/sorbet_result. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/sorbet_result/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SorbetResult project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sorbet_result/blob/main/CODE_OF_CONDUCT.md).
