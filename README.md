
# Installation

Ruby 1.9.2 or greater is required.

    > gem install cknife
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

## AWS Key and Secret Configuration

In order of priority, Setup your key and secret with:

  - $CWD/cknife.yml
  - $CWD/tmp/cknife.yml
  - environment variables: `KEY`, `SECRET`
  - environment variablse: `AMAZON_ACCESS_KEY_ID`, `AMAZON_SECRET_ACCESS_KEY` 

The format of your cknife.yml must be like so:

    ---
    key: AKIAblahblahb...
    secret: 8xILhOsecretsecretsecretsecret...

# Overview

Cali Army Knife, or cknife, is an Amazon Web Services S3 command line
tool, and a few other command line tools, packaged as a Ruby
gem. Written in Ruby with Thor. It depends on the Fog gem for all of
its S3 operations.

Uses multipart uploads with a chunksize of 10 megabytes to keep RAM
usage down.

The premier feature of the tool is the "upsync" command, which can be
used to run a backups schedule with multiple classes of files
(partitioned by a glob pattern). **It is your responsibility to
generate one uniquely-named backup file per day**, as this tool does
not do that part for you.

If you *don't* use the `backups-retain` option, then its like a very
weak **rsync** that can upload from a local filesystem into a bucket.
Which is also pretty useful.

[Github Link](https://github.com/mikedll/cali-army-knife)

Some examples:

Download entire my-photos bucke to CWD

    > cknifeaws download my-photos 
    
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

### Synchronizing a local directory's files with an Amazon S3 Bucket

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

The glob allows you to determine whether you want to recursively
upload an entire directory, or just a set of *.dat or *.sql files,
ignoring whatever else may be in the specified directory. This glob
pattern is appended to the directory you specify.

For determining whether to upload a file, first the mod time is used,
and if that match fails, an md5 checksum comparison is used.

The file's local modification time, from the file system from which it
was uploaded, is used to determined whether it qualifies for retention
in the backup program you specify.

This info is uploaded with the file to Amazon's S3 servers when the
file is uploaded, in the S3 file metadata. Without this, S3 uses a
modtime that is equal to when the file was last uploaded, which is not
comparable to the file's local mod time.

### Dumping an Amazon S3 bucket

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


