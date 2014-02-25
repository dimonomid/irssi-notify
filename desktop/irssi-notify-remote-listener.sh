#!/bin/sh
set -e

# get path to this script
DIR="$(dirname $(readlink -f "$0"))"

# Based on:
#   http://thorstenl.blogspot.com/2007/01/thls-irssi-notification-script.html

# set default options {{{

# file for storing list of currently plugged devices

notification_on_command="/bin/bash $DIR/notification_on.sh"
notification_off_command="/bin/bash $DIR/notification_off.sh"

remote_notifylog_file_path="~/.irssi/notifylog"

# }}}

# read config file {{{
#{
   #if [ -r /etc/my-udev-notify.conf ]; then
      #. /etc/my-udev-notify.conf
   #fi
   #if [ -r ~/.my-udev-notify.conf ]; then
      #. ~/.my-udev-notify.conf
   #fi
#}
# }}}

DEHILIGHT_KEYWORD="---dehighlight---"

# TODO: make it modular: at least, need to add a function to "unnotify", 
#       and probably there should be not functions but shell commands

notify()
{
   $notification_on_command -h "$1" -m "$2"
}

remove_notification()
{
   $notification_off_command
}



while true; do

   echo "retrieving existing unread messages.."

   # -----------------------------------------------------------------------------------
   # First of all, let's retrieve existing unread messages

   tmpfilename=`mktemp`
   ssh -n user@77.221.148.122 "tail -n 10 $remote_notifylog_file_path" > $tmpfilename

   first_unread_linenum=`cat $tmpfilename | \
      awk \
      -v deh_keyword="$DEHILIGHT_KEYWORD" \
      'BEGIN {linenum=1} {if ($1 == deh_keyword){linenum = NR + 1}}  END {print linenum}'`

   linecnt=`cat $tmpfilename | awk 'END {print NR}'`

   #echo "linecnt=$linecnt"
   #echo "first_unread_linenum=$first_unread_linenum"
   echo "existing unread messages: $(( $linecnt - $first_unread_linenum + 1))"

   cur_linenum=$first_unread_linenum

   remove_notification

   while [ $cur_linenum -le $linecnt ]
   do
      tmpfilename_part=`mktemp`
      cat $tmpfilename | \
         sed -n "$cur_linenum"p | \
         sed -u 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/\\/\\\\/g' \
         > $tmpfilename_part

      while read heading message; do
         echo "existing unread message: ${heading} -> ${message}"
         notify "${heading}" "${message}"
      done < $tmpfilename_part

      rm $tmpfilename_part
      cur_linenum=$(($cur_linenum + 1))
   done

   rm $tmpfilename


   # -----------------------------------------------------------------------------------
   # Now, listen for new messages

   echo "listening for new messages.."

   ssh -o ServerAliveInterval=240 -n user@77.221.148.122 "tail -n 0 -f $remote_notifylog_file_path" | \
      sed -u 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/\\/\\\\/g' | \
      while read heading message; do
         if [ "${heading}" != "$DEHILIGHT_KEYWORD" ]; then
            echo "new message received: ${heading} -> ${message}"
            notify "${heading}" "${message}"
         else
            echo "messages were read; removing notifications"
            remove_notification
         fi
      done

      echo "restarting listener.."
   done

   echo "exiting."

