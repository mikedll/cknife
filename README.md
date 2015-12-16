
# Overview

Please pay a fee to use this software. I'm Michael Rivera, its owner,
available at mrivera@michaelriveraco.com.

Cali Army Knife, cknife, is a collection of command line tools
implemented with Thor.

# Installation

This can be done after you purchase the software.

The gem has been used with Rubies >= 1.9.2 and activesupport >= 3.

1. Install ruby:

    > \curl -sSL https://get.rvm.io | bash -s stable --ruby

2. Create a Gemfile with cknife and its git repository. Run bundle.

The above instructions have not been tested.

# Computer Monitor

This sends out a PUT request every fifteen minutes to a server
you configure.

# Amazon Web Services (AWS) Command Line Interface

    > cknifeaws help
    Tasks:
      cknifeaws afew [BUCKET_NAME]                # Show first 5 files in bucket
      cknifeaws create [BUCKET_NAME]              # Create a bucket
      cknifeaws create_cloudfront [BUCKET_NAME]   # Create a cloudfront distribution (a CDN)
      cknifeaws delete [BUCKET_NAME]              # Destroy a bucket
      cknifeaws download [BUCKET_NAME]            # Download all files in a bucket to CWD. Or one file.
      cknifeaws help [TASK]                       # Describe available tasks or one specific task
      cknifeaws list                              # Show all buckets
      cknifeaws list_cloudfront                   # List cloudfront distributions (CDNs)
      cknifeaws list_servers                      # Show all servers
      cknifeaws show [BUCKET_NAME]                # Show info about bucket
      cknifeaws start_server [SERVER_ID]          # Start a given EC2 server
      cknifeaws stop_server [SERVER_ID]           # Stop a given EC2 server (does not terminate it)
      cknifeaws upsync [BUCKET_NAME] [DIRECTORY]  # Push local files matching glob PATTERN into bucket. Ignore unchanged files.      

### AWS Key and Secret Configuration

Setup your AWS key and secret in any of these methods, in order of priority:

  - $CWD/cknife.yml
  - $CWD/tmp/cknife.yml
  - environment variables: `KEY`, `SECRET`
  - environment variablse: `AMAZON_ACCESS_KEY_ID`, `AMAZON_SECRET_ACCESS_KEY` 

The format of your cknife.yml must be like so:

    ---
    key: AKIAblahblahb...
    secret: 8xILhOsecretsecretsecretsecret...

### Upload a local directory into an S3 Bucket

    Usage:
      cknifeaws upsync [BUCKET_NAME] [DIRECTORY]

    Options:
      [--public]             
      [--region=REGION]      
                             # Default: us-east-1
      [--noprompt=NOPROMPT]  
      [--glob=GLOB]          
                             # Default: **/*
      [--backups-retain]     
      [--days-retain=N]      
                             # Default: 30
      [--months-retain=N]    
                             # Default: 3
      [--weeks-retain=N]     
                             # Default: 5
      [--dry-run]            

Some examples:

Upload and sync `/tmp/*.sql` into `my-frog-app-backups`
bucket. Treat the files as backup files, and keep one backup
file for each of the last 5 months, 10 weeks, and 30 days.    

    > cknifeaws upsync my-frog-app-backups ./tmp --glob "*.sql" --noprompt --backups-retain true --months-retain 5 --weeks-retain 10 --days-retain 30

As above, but now do redis backup files (`./tmp/*.rdb`). these will
not produce namespace collisions with the sql files, and thus the same
bucket can be used to store backups for both .sql and .rdb files.

    > cknifeaws upsync my-frog-app-backups ./tmp --glob "*.rdb" --noprompt --backups-retain true --months-retain 5 --weeks-retain 10 --days-retain 30

**DO NOT DO THIS INSTEAD OF THE ABOVE 2 COMMANDS, THINKING IT WILL
TREAT .SQL AND .RDB FILES SEPARATELY. INSTEAD, YOU WILL LOSE
SOME OF YOUR BACKUP FILES.**

    > cknifeaws upsync my-frog-app-backups ./tmp --glob "*" --noprompt --backups-retain true --months-retain 5 --weeks-retain 10 --days-retain 30

Dry run mode. Try one of the prior backups retain commands, but
let's see what will happen, first.

    > cknifeaws upsync my-frog-app-backups ./tmp --glob "*.sql" --noprompt --backups-retain true --months-retain 5 --weeks-retain 10 --days-retain 30 --dry-run

This is the premier feature of the gem.

Uses multipart uploads with a chunksize of 10 megabytes to keep RAM
usage down.

It can be used to run a backups schedule with multiple classes of
files (partitioned by a glob pattern). **It is your responsibility to
generate one uniquely-named backup file per day**, as this tool does
not do that part for you.

If you *don't* use the `backups-retain` option, then its like a very
weak **rsync** that can upload from a local filesystem into a bucket.
Which is also pretty useful.

The glob allows you to determine whether you want to recursively
upload an entire directory, or just a set of *.dat or *.sql files,
ignoring whatever else may be in the specified directory. This glob
pattern is appended to the directory you specify.

For determining whether to upload a file, it uses the file's local
filesystem modification time, and if there is a mismatch then it does
an md5 checksum comparison, and if there is a mismatch there, then the
local file will replace the remote one in S3. The file's local
filesystem modification time is stored on S3 in the S3 object's
metadata when the file is uploaded.

### Download an S3 bucket to a local directory

Sometimes you want to download an entire S3 bucket to your local
directory - a set of photos, for example.

    > cknifeaws help download 
    Usage:
      cknifeaws download [BUCKET_NAME]

    Options:
      [--region=REGION]  
                         # Default: us-east-1
      [--one=ONE]        

    Download all files in a bucket to CWD. Or one file.

Download entire my-photos bucket to CWD

    > cknifeaws download my-photos 

# SMTP Email Command Line Interface

    > cknifemail help
    Tasks:
      cknifemail help [TASK]                             # Describe available tasks or one specific task
      cknifemail mail [RECIPIENT] [SUBJECT] [TEXT_FILE]  # Send an email to recipient.

Only simple email sending is available here, for now.

### Send an email

    > bundle exec ./bin/cknifemail help mail 
    Usage:
      cknifemail mail [RECIPIENT] [SUBJECT] [TEXT_FILE]

    Options:
      [--from=FROM]      
      [--simple-format]  
                         # Default: true

The `simple_format` option is available to help format plaintext
emails whose bodies you don't want messed up when newlines are ignored
with html formatting. This is helpful for when log files are included
in email bodies, which is the primary expectation for how this will
be used.

Has been successfully tested with the SMTP interface to Amazon SES and
Sendgrid. Should work with Postmark just fine.

This **requires** the cknife YAML config, with the following field structure.

    mail:
      from: "Rick Santana <rick.santana@example.com>"
      authentication: login
      address: smtp-server
      port: smtp-port (defaults to 587)
      username: yoursmtpusername
      password: yoursmtppassword
      domain: domain-if-you-like.com



# Zerigo Command Line Interface

The These tasks can be used to manage your DNS via Zerigo.  They changed
their rates drastically with little notice in January of 2014, so I
switched to DNS Simple and don't use this much anymore.

    > cknifezerigo help
    Tasks:
      cknifezerigo create [HOST_NAME]  # Create a host
      cknifezerigo delete [ID]         # Delete an entry by id
      cknifezerigo help [TASK]         # Describe available tasks or one specific task
      cknifezerigo list                # List available host names.

# PostgreSQL Backups

This is a wrapper around the PostgreSQL backup and restore command
line utilities.

It requires the following Rails-style configuration in the
configuration file:

    pg:
      host: localhost
      database: dbname
      username: dbuser
      password: dbpassword

**Warning:** do not use a colon in your password, or the password
configuration will not work. This is a shortcoming of this project and
a consequence of the `.pgpass` file format used by PostgreSQL.

Then you can capture a snapshot of your database. You can also restore
it using this tool.

    > bundle exec cknifepg help 
    Tasks:
      cknifepg capture      # Capture a dump of the database to db(current timestamp).dump.
      cknifepg disconnect   # Disconnect all sessions from the database. You must have a superuser configured for this to work.
      cknifepg help [TASK]  # Describe available tasks or one specific task
      cknifepg restore      # Restore a file. Use the one with the most recent mtime by default. Searches for db*.dump files in the CWD.
      cknifepg sessions     # List active sessions in this database and provide a string suitable for giving to kill for stopping those sessions.

This generates and deletes a `.pgpass` file before and after the
command line session. Be aware that if this process is interrupted,
the `.pgpass` file may be left on disk in the CWD.

# MySQL Backups

Like pg, this requires a similar setup in the configuration:

    mysql:
      host: localhost
      database: dbname
      username: dbuser
      password: dbpassword

Then you can capture a snapshot of your database.

    > bundle exec cknifemysql help 
    Tasks:
      cknifemysql capture      # Capture a dump of the database to db(current timestamp).sql.
      cknifemysql help [TASK]  # Describe available tasks or one specific task
      cknifemysql restore      # Restore a file. Use the one with the most recent mtime by default. Searches for db*.sql files in the CWD.

Sample output:

    > bundle exec cknifemysql capture 
    mysqldump --defaults-file=my.cnf -h localhost -P 3306 -u dbuser dbname --add-drop-database --result-file=db20150617125335.sql
    Captured db20150617125335.sql.

And the accompanying restore, were you to run it immediately afterwards:

    > bundle exec cknifemysql restore 
    Restore db20150617125335.sql? y
    Doing restore...
    mysql --defaults-file=my.cnf -h localhost -P 3306 -u dbuser dbname
    source db20150617125335.sql;
    Restored db20150617125335.sql

**Important:** As you can see, a my.cnf is generated and your password
stored in there. That file is removed when the command is done
executing.  This keeps your password off of the command line and
hidden from certain `top` or `ps` invocations by other users who may
be on the same machine. This rational is taken from the PostgreSQL
PGPASSFILE documentation. If this command error's-out, you'll be
warned to remove this file yourself for security purposes.

# Dub

Like du, but sorts your output by size.  This helps you determine
which directories are taking up the most space:

    > cknifedub
          37.0G .
          23.0G ./Personal
          14.0G ./Library
         673.0M ./Work
           0.0B ./Colloquy Transcripts

Options:

    -c Enable colorized output. 

# A typical cron script for capturing PostgreSQL backups and uploading them to S3

    #!/bin/bash
    
    source "$HOME/.rvm/scripts/rvm";

    rvm use 2.0.0;

    cd path/to/backups/dir/with/cknife/config;

    cknifepg capture;

    cknifeaws upsync backups-bucket . --noprompt --backups-retain --glob="db*.dump";

    find -mtime +7 -iname "*.dump" -delete
    
Which can be used with the following sample [crontab](http://en.wikipedia.org/wiki/Cron#Examples),
executing once a day at 2am:

    # * * * * *  command to execute
    # │ │ │ │ │
    # │ │ │ │ │
    # │ │ │ │ └───── day of week (0 - 6) (0 to 6 are Sunday to Saturday, or use names; 7 is Sunday, the same as 0)
    # │ │ │ └────────── month (1 - 12)
    # │ │ └─────────────── day of month (1 - 31)
    # │ └──────────────────── hour (0 - 23)
    # └───────────────────────── min (0 - 59)

    0 2 * * *  path/to/script > /dev/null


# Contributing

### Making a release

This section is outdated as of December 15th, 2015. It has
to be updated to reflect that this will not be hosted on
Rubygems.

One of the following, like patch. This will create a git commit.

    bundle exec rake version:bump:major
    bundle exec rake version:bump:minor
    bundle exec rake version:bump:patch

Create the gem spec.

    bundle exec rake gemspec:generate
    git add -A
    git commit -m "Generated gemspec for version 0.1.4"

Make a gem release. This will generate a commit and a tag for v0.1.2.

    bundle exec rake release

You may also build a raw gem for testing installs without
releasing to Rubygems publically. Use scp
to move this .gem file to a machine you want to install
on:

    bundle exec rake build

If a gem is already built, you can remove it with
something like the following:

    rm pkg/cknife-0.1.6.gem

### Invoking commands without clobbering the gemspec

You can uncommente the 'gem cknife' line in the Gemfile.

Then you can invoke the executables as you work on them.

Do not generate the .gemspec with this line uncommented, or
you'll create a self-dependency in this gem.

Run bundle after uncommenting the line then use `bundle exec cmd`
to invoke a given command named "cmd".


