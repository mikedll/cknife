
The example deployment user here has username `alexan`. (Alexa N.)

This presumes an Ubunto 14.x server base installation.

    > lsb_release -a 
    No LSB modules are available.
    Distributor ID:	Ubuntu
    Description:	Ubuntu 14.04.5 LTS
    Release:	14.04
    Codename:	trusty

# Non-root user creation

Applications are expected to be served from that user's home
directory.

    > adduser -G sudo alexan

Provide a password. Answer some questions.

    > usermod -a -G sudo alexan 
    > groups alexan
    alexan : alexan sudo

You may inspect the sudo file:

    > less /etc/sudoers

    ...

    # Members of the admin group may gain root privileges.
    %admin ALL=(ALL) ALL

    # Allow members of group sudo to execute any command
    %sudo	ALL=(ALL:ALL) ALL

# Upgrade to latest release.

This is not recommended at this time. This could upgrade to Ubuntu 16.x.

    # > sudo do-release-upgrade
    
# Directory Structure

Ensure you create these directories:

    mkdir ~/backups
    mkdir ~/packages

Pick a package directory like the packages directory described
above for doing package building.

# Passwordless Login Setup

Ensure you have a key installed for this user. You're about
to lose access to the root account.

    > cd ~
    > mkdir .ssh
    > chmod 700 .ssh 
    > touch ~/.ssh/authorized_keys
    > chomd 644 ~/.ssh/authorized_keys 
    > vi ~/.ssh/authorized_keys

Paste in your .pub contents. Save the file.

Test the machine to verify that you can do a passwordless login.

Then you are ready to turn off password logins.

# Disable Password Logins

**Requires** that you've completed Passwordless Login Setup, or you'll
lose control of your machine.

    > sudo vi /etc/ssh/sshd_config
    
    ...
    
    PubkeyAuthentication yes
    ...
    ChallengeResponseAuthentication no
    ...
    PasswordAuthentication no            # you'll likely change this line.

You may further setup this machine for your purposes.
