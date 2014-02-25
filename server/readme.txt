
"notifylog" dir contains scripts for adding events to the notifylog file that
will be read by clients. So, unpack the whole "notifylog" somewhere in your
system.

copy ./irssi_script/hilightnotify.pl to ~/.irssi/scripts

modify paths in it: 

  - look for "hilight_cmd_on_hilight" option, set path
    to your notifylog/irssi_highlight.pl
  - look for "hilight_cmd_on_dehilight" option, set path
    to your notifylog/irssi_dehighlight.pl

create an autorun link:
ln -s ~/.irssi/scripts/hilightnotify.pl ~/.irssi/scripts/autorun/hilightnotify.pl

then, restart your irssi, or just type in it:

/script load hilightnotify

and one more step: create empty file ~/.irssi/notifylog , permissions 644 are
fine. 
(if you don't create, it will be created at first notify event, but it's
better to create it now since you can set up clients immediately)

Done!

