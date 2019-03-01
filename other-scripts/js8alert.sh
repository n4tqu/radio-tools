#!/bin/bash

#this script will read the js8 message database
#and send a text message via JS8 to alert you that
#you have messages waiting in JS8
#This script should be run by cron every 30-60 minutes
#This script will continue to alert you until the message
#flag has been cleared in JS8
#Hint: Enter line below in crontab to run every 30 minutes
#       */30 * * * * /usr/local/bin/js8alert
#Thanks to Jerry K7AZJ for help cleaning up this script!!
#This script is provided AS IS
#Feel free to mod for your use
#km4ack 20190106

########USER VARIABLES#############

#Enter phone number or alias to text with alert
#more about alias at http://smsgte.wixsite.com/smsgte
#remove me on line below and add phone number. example phone=5551234567
phone=me

#alert text to send to mobile device
#You can change what is in quotes on next line
alert="You have JS8 msgs"

#######END USER VARIABLES#########

#check if sqlite3 is installed
#and give option to install if not
pkg=$(dpkg -l | grep 'sqlite3 ')

if [[ -z "$pkg" ]]; then
   echo "SQLite is not installed on this machine"
   echo "Would you like to install it now?"
   echo "yes or no"
   read ans
        if [ $ans = "yes" ]
        then
        sudo apt-get install -y sqlite3
        echo
        echo
        echo "Install Successful"
        else
        exit 0
        fi
else
echo
fi


DBF=$HOME/.local/share/JS8Call/inbox.db3
OUTDIR=$HOME/temp
OUTFILE=$OUTDIR/temp-dbsearch.txt

# make sure the output directory exists
mkdir -p $OUTDIR

# sqlite3 allows us to do a command from the command line
sqlite3 $DBF 'select * from inbox_v1;' > $OUTFILE


# grep "UNREAD" in the output file, we don't care about results, just whether it found any
grep -q "UNREAD" $OUTFILE > /dev/null
# grep -q will set exit variable $? 0 = "UNREAD" found, 1 = not found

if [ "$?" == "0" ]; then
  #forward the alert to JS8 for sending
  value="\"@ALLCALL APRS::SMSGTE   :@${phone} ${alert}\""
  printf '{"params": {}, "type": "TX.SEND_MESSAGE", "value": %s}\n' "${value}" | nc -l -u -w 10 2237
else
   echo "No New Messages"
fi

#remove temp text file
rm -f $OUTFILE
