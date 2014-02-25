#!/usr/bin/perl

use strict;
use warnings;

our $VERSION = '1.0';
our %IRSSI = (
   authors     => 'Daniel Andersson',
   contact     => 'sskraep@gmail.com',
   name        => 'hilightnotify',
   description => 'Executes command on hilight and dehilight',
   license     => 'GNU GPL v2 or later',
   url         => 'http://510x.se/notes',
   changed     => '2012-02-12',
);


open(FILE,">>$ENV{HOME}/.irssi/notifylog");
print FILE "$ARGV[0] $ARGV[1]" . "\n";
close (FILE);

