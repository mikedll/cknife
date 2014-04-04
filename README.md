Cali Army Knife
==============

An Amazon Web Services S3 command line tool, and a few other command
line tools. Written in Ruby with Thor.

[Github Link](https://github.com/mikedll/cali-army-knife)


Examples:

    # download my-photos buckest
    > aws download my-photos 
    
    # upload and sync /tmp/*.sql into my-frog-app-backups
    # bucket. Treat the files as backup files, and keep one backup
    # file for each of the last 10 months, 10 weeks, and 30 days.    
    > aws upsync my-frog-app-backups ./tmp --glob "*.sql" --noprompt --backups-retain true --months-retain 5 --weeks-retain 10 --days-retain 30

    # As above, but see we'll happen first with dry run.
    > aws upsync my-frog-app-backups ./tmp --glob "*.sql" --noprompt --backups-retain true --months-retain 5 --weeks-retain 10 --days-retain 30 --dry-run

# aws

    Tasks:
      aws.rb afew [BUCKET_NAME]                # Show first 5 files in bucket
      aws.rb create [BUCKET_NAME]              # Create a bucket
      aws.rb create_cloudfront [BUCKET_NAME]   # Create a cloudfront distribution (a CDN)
      aws.rb delete [BUCKET_NAME]              # Destroy a bucket
      aws.rb download [BUCKET_NAME]            # Download all files in a bucket to CWD. Or one file.
      aws.rb help [TASK]                       # Describe available tasks or one specific task
      aws.rb list                              # Show all buckets
      aws.rb list_cloudfront                   # List cloudfront distributions (CDNs)
      aws.rb list_servers                      # Show all servers
      aws.rb show [BUCKET_NAME]                # Show info about bucket
      aws.rb start_server [SERVER_ID]          # Start a given EC2 server
      aws.rb stop_server [SERVER_ID]           # Stop a given EC2 server (does not terminate it)
      aws.rb upsync [BUCKET_NAME] [DIRECTORY]  # Push local files matching glob PATTERN into bucket. Ignore unchanged files.      

## Synchronizing a local directory's files with an Amazon S3 Bucket

    Usage:
      aws.rb upsync [BUCKET_NAME] [DIRECTORY]

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

## Dumping an Amazon S3 bucket

Sometimes you want to download an entire S3 bucket to your local
directory - a set of photos, for example.

    > aws help download 
    Usage:
      aws.rb download [BUCKET_NAME]

    Options:
      [--region=REGION]  
                         # Default: us-east-1
      [--one=ONE]        

    Download all files in a bucket to CWD. Or one file.


## Key and Secret Configuration

In order of priority, Setup your key and secret with:

  - $CWD/cknife.yml
  - $CWD/tmp/cknife.yml
  - environment variables: `KEY`, `SECRET`
  - environment variablse: `AMAZON_ACCESS_KEY_ID`, `AMAZON_SECRET_ACCESS_KEY` 

The format of your cknife.yml must be like so:

    ---
    key: AKIAblahblahb...
    secret: 8xILhOsecretsecretsecretsecret...


# zerigo 

These tasks can be used to manage your DNS via Zerigo.  They changed
their rates drastically with little notice in January of 2014, so I
switched to DNS Simple and don't use this much anymore.

    > zerigo 
    Tasks:
      zerigo.rb create [HOST_NAME]  # Create a host
      zerigo.rb delete [ID]         # Delete an entry by id
      zerigo.rb help [TASK]         # Describe available tasks or one specific task
      zerigo.rb list                # List available host names.

# dub

Like du, but sorts your output by size.  This helps you determine
which directories are taking up the most space:

    > dub
          37.0G .
          23.0G ./Personal
          14.0G ./Library
         673.0M ./Work
           0.0B ./Colloquy Transcripts

## options      

    -c Enable colorized output. 
