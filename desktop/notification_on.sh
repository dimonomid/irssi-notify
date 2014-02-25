#!/bin/sh

DIR="$(dirname $(readlink -f "$0"))"

# retrieve options from command line {{{

heading=
message=

while getopts h:m: opt; do
  case $opt in
  h)
      heading=$OPTARG
      ;;
  m)
      message=$OPTARG
      ;;
  esac
done

shift $((OPTIND - 1))
# }}}

# show notification via libnotify (for 10 seconds)
notify-send -i gtk-dialog-info -t 10000 -- "${heading}" "${message}"

# play sound
play -q $DIR/sounds/message.wav &

# show tray blinking icon
$DIR/irssi-tray/irssi-tray.pl &



