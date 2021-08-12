#!/bin/sh

# FTP Server
HOST='server.address'

# FTP Username
USER='username'

# FTP Password
PASSWD='ftp.password'

# Original system filename to transfer
FILE='file.to.transfer.txt'

# System directory original file is in
DIR=`pwd`"/dir/"

# FTP directory file should be saved in
FTPDIR='ftpdir/'

# Store our date in format of month.day.year-hour.minute.second
DATE=$(date +"%m.%d.%Y-%H.%M.%S")

# Filename to rename system file to
NEWFILE='einvoice-'$DATE'.txt'

# Email address to send error reporting to
ADMINEMAIL='admin@email.com'

# See who the current system user is
# echo `whoami`

# See what our current directory is
# echo `pwd`

# Change working directory to $DIR
cd $DIR

# Make sure the system file exists
if [ -f "$DIR$FILE" ]
then
    echo "Attempting to upload $DIR$FILE"

    # FTP command to execute. This will transer the $FILE then try to download it to
    # verify that it was successfully uploaded
    ftp -nv $HOST > $DIR/ftp.log.txt <<ENDSCRIPT
    quote USER $USER
    quote PASS $PASSWD
    passive
    cd $FTPDIR
    put $FILE
    get $FILE INVOICE2.$$.TXT
    bye
    quit
ENDSCRIPT

    # Make sure our downloaded FTP file exists, meaning the transfer was successful
    if [ -f $DIR"INVOICE2.$$.TXT" ]
    then
        # Delete the temporary download verification file
        rm $DIR"INVOICE2.$$.TXT"

        # Move/rename the original file to a filename that contains today's date for backup
        mv "$DIR$FILE" "$DIR$NEWFILE"

        # Print some information on the sceen
        echo "FTP of $DIR$FILE to $HOST worked. File renamed from $DIR$FILE to $DIR$NEWFILE"

    # Our FTP verification file doesn't exist. The transfer failed.
    else
        RESULT="FTP of $DIR$FILE to $HOST did not work"
        echo $RESULT

        (echo "FTP File Upload to Tungsten Failed!!"; cat ftp.failed.txt) | mailx -s "Tungsten FTP File Upload Failed" $ADMINEMAIL

    fi
fi

# Our local file to upload doesn't exist
#else
#    echo "Local file ($DIR$FILE) doesn't exist"
#    (echo "FTP File Upload to Tungsten Failed!! Source file was not found"; cat ftp.failed.txt) | mailx -s "Tungsten FTP File Doesn't Exist" $ADMINEMAIL
#fi

exit 0
