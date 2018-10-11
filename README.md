
# Quickstart

cknife is a set of command line tools. They...do different things.

    > \curl -sSL https://get.rvm.io | bash -s stable --ruby
    > gem install cknife

Create `$CWD/tmp/cknife.yml` and put in a AWS key-secret pair:

    ---
    key: AKIAblahblahb...
    secret: 8xILhOsecretsecretsecretsecret...

Then invoke the `cknifeaws` tool.

    > cknifeaws afew your-bucket-name

That will show you a few files in that Amazon S3 bucket of yours
named `your-bucket-name`.

    > cknifeaws afew my-bucket --count=50
    
That will show you 50 of them. You can see the help for this command, too.

    > cknifeaws help

See the
[Wiki](https://github.com/mikedll/cknife/wiki) for details on the
tools cknife has. A complete list of the tools is below under 'usage'.

# Requirements

  - Ruby >= 2.4. Older versions work to some extent with older rubies.

The cknife executables are implemented with the Ruby
[Thor](https://github.com/erikhuda/thor) gem.

# Installation

Install Ruby and possibly bundler:

    > \curl -sSL https://get.rvm.io | bash -s stable --ruby
    > gem install bundler

Add cknife to a Gemfile.

    source "http://rubygems.org"
    git_source(:github) { |repo| "https://github.com/#{repo}.git" }

    gem "cknife", '~> 1.1.0'

Run bundle.

    > bundle

# Usage

The cknife tools make use of a common configuration file. It uses a
YAML format. It is named `cknife.yml` and the tools look for it in
these two places, in order:

  - $CWD/cknife.yml
  - $CWD/tmp/cknife.yml

Here are the command line executables:

  - cknifeaws - AWS wrappers.
  - cknifemail - SMTP email sender.
  - cknifemon - Daemon that sends heartbeat signals to a place of your choosing.
  - cknifemysql - MySQL utilities.
  - cknifepg - PostgreSQL utilities.
  - cknifewcdir - Lines-of-code calculator.
  - cknifedub - Spot directories that are particularly space-consuming.
  - cknifenowtimestamp - Get a now() timestamp string.

You can invoke any of them like this:

    bundle exec cknifeaws

# Security Awareness

Since the `cknife.yml` holds sensitive information in the name of
convenience, you may choose to erase it after you're done with what
you're doing with it. It depends on your use, of course. You probably
want to add it to your `.gitignore` file if you're using it on a
per-project basis.

# Development

## Making a release

One of the following, like patch. This will create a git commit.

    bundle exec rake version:bump:major
    bundle exec rake version:bump:minor
    bundle exec rake version:bump:patch

Do a git flow release. Create the gem spec and commit it:

    bundle exec rake gemspec:generate
    git commit -am "Generated gemspec for version 1.3.0"

Do a git flow finish release. Push to github. You can
then do a release to Rubygems. This command will
try to generate the gemspec, but nothing will happen
since the gemspec is already valid.

    rake release

## Building Locally (Optional)

You may build a local gem:

    bundle exec rake build

And remove it:

    rm pkg/cknife-0.1.6.gem

## Invoking commands without clobbering the gemspec

You can uncommente the 'gem cknife' line in the Gemfile.

Then you can invoke the executables as you work on them.

Do not generate the .gemspec with this line uncommented, or
you'll create a self-dependency in this gem.

Run bundle after uncommenting the line then use `bundle exec cmd`
to invoke a given command named "cmd".


