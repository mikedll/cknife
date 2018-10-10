
# Overview

What do you do when you don't want to write
[bash](https://www.tldp.org/LDP/Bash-Beginners-Guide/html/Bash-Beginners-Guide.html),
your `.bash_profile` already has more aliases than you can manage, and
yet you still find it silly to be going to the same [old documentation
websites](https://www.postgresql.org/docs/9.5/static/backup-dump.html)
for things you are certain you once knew how to do?

Well, you can write a script in something other than
bash to automate the precise command line invocation
that you used to accomplish a task. But when you
move to a different project, how can you take your
scripts with you? Why not design your scripts
to be robust enough so that they are conventional?

Why can't a [Stackoverflow](https://stackoverflow.com) question's
answer be captured in a form that can be configured and called by you
(or someone who was in your position before), so that you don't have
to enter the same question into
[google.com](https://www.google.com/?q=LOL%20HALP%20ME%20CODE) again
later down the road?

Why make a browser bookmark if you can skip the browser entirely?
It's not like the browser bookmark can compile the answer into machine
code for you, anyway.

If someone turns the answer into a programmed tool, what if your IDE
is no better than the command line when it comes to invoking it?

I created cknife to have a set of scripts to fall back on when
confronted with the above encounter I've been having for years. cknife
is a toolset that encapsulates common command line expressions that
developers use when at work.

I've never used [chef](https://www.chef.io), but were I to grow
cknife, I wouldn't be surprised to see it overlap with it.

cknife currently has some wrappers around Amazon's EC2 and S3
services. It has others around MySQL and PostgreSQL. It has a trivial
one around [du](http://man7.org/linux/man-pages/man1/du.1.html).  The
`cknifemon` tool, meanwhile, is a daemon that can launch PUT HTTP
requests to an endpoint you configure, on a schedule.

It can be used for system administration, but it can be also be used
to aid developers as they acclimate themselves to a piece of
technology with which they may not be familiar, and for which
documentation may be a little scattered. It can be used
to bang on a piece of technology for the sake of your own
learning, too.

To be precise, cknife consists of command line executables. The tools
often require more information from the user, which can be put into a
configuration file (`cknife.yml`) in YAML format, and found by cknife
in the current working directory ($CWD) when it is invoked.

See the [Wiki](https://github.com/mikedll/cknife/wiki) for
more documentation.

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

  - cknifeaws
  - cknifedub
  - cknifemail  
  - cknifemon
  - cknifemysql
  - cknifenowtimestamp
  - cknifepg
  - cknifewcdir

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
    git commit -am "Generated gemspec for version 0.1.4"

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


