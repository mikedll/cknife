Cali Army Knife
==============

Various Thor tasks arranged as command line tools, and then some other
command line tool wrappers that don't use Thor.

# zerigo 

    > zerigo 
    Tasks:
      zerigo.rb create [HOST_NAME]  # Create a host
      zerigo.rb delete [ID]         # Delete an entry by id
      zerigo.rb help [TASK]         # Describe available tasks or one specific task
      zerigo.rb list                # List available host names.

# aws

    > aws 
    Tasks:
      aws.rb afew [BUCKET_NAME]      # Show first 5 files in bucket
      aws.rb create [BUCKET_NAME]    # Create a bucket
      aws.rb delete [BUCKET_NAME]    # Show all buckets
      aws.rb download [BUCKET_NAME]  # Show files in bucket
      aws.rb help [TASK]             # Describe available tasks or one specific task
      aws.rb list                    # Show all buckets

# dub

Like du, but sorts your output by size. Compare:

### du

    > du -h -d 1 
      0B	./Colloquy Transcripts
     14G	./Library
     23G	./Personal
    673M	./Work
     37G	.


### dub:

    > dub
          37.0G .
          23.0G ./Personal
          14.0G ./Library
         673.0M ./Work
           0.0B ./Colloquy Transcripts

## options      

    -c Enable colorized output. 
