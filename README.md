# <a name="title"></a> Campy [![Build Status](https://secure.travis-ci.org/fnichol/campy.png)](http://travis-ci.org/fnichol/campy)

Tiny Campfire Ruby client so you can get on with it. It's implemented on top of
`Net::HTTP` and only requires the `multi_json` gem for Ruby compatibilities.

## <a name="installation"></a> Installation

Add this line to your application's Gemfile:

```ruby
gem 'campy'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```
$ gem install campy
```

## <a name="usage"></a> Usage

First create a `campfire.yml` file in your home directory:

```bash
$ cat <<CAMPFIRE_YAML > $HOME/.campfire.yml
:account: mysubdomain
:token: mytoken123
:room: House of Hubot
CAMPFIRE_YAML
```

### <a name="usage-bin"></a> campy Command

Campy comes with the `campy` command so you can send messages from the
command line:

```bash
$ campy speak "Campy says yello"
$ campy play ohmy
```

### <a name="usage-ruby"></a> Ruby Library

There's not much to the API; create a `Campy::Room` and go:

```ruby
require 'campy'

campy = Campy::Room.new(:account => "mysubdomain",
  :token => "mytoken123", :room => "House of Hubot")
campy.speak "Campy says yello"
campy.play "ohmy"
```

Why not use the `campfire.yml` config? Let's do that:

```ruby
require 'campy'
require 'yaml'

campy = Campy::Room.new(YAML.load_file(
  File.expand_path("~/.campfire.yml")))
campy.speak "Campy says yello"
campy.play "ohmy"
```

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Fletcher Nichol][fnichol] (<fnichol@nichol.ca>)

## <a name="license"></a> License

MIT (see [LICENSE][license])

[license]:      https://github.com/fnichol/campy/blob/master/LICENSE
[fnichol]:      https://github.com/fnichol
[repo]:         https://github.com/fnichol/campy
[issues]:       https://github.com/fnichol/campy/issues
[contributors]: https://github.com/fnichol/campy/contributors
