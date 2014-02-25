#!/usr/bin/perl

use strict;
use warnings;
use Gtk2;
use Gtk2::TrayIcon;
use Proc::ProcessTable;
use File::Basename;


# TRAYBLINKER  -  Create blinking tray icon, execute command on click
#
# USAGE
#     Define icon paths and activation action in the script. Then run as
#     standalone script.
#
#     The script sends its process number as argument to the external script
#     and terminates with visual indication on SIGUSR1. Use this in the script
#     that is called to automatically terminate the blinking tray icon.

if (&already_running) {
   #print 'Already running, exiting.' if $ENV{'tty'};
   print "Already running, exiting.\n";
   exit(0);
}

sub already_running
{

   my $table = new Proc::ProcessTable;
   my $scriptname = basename($0);
   foreach my $process (@{$table->table}) {
      return 1 if ($process->fname() eq $scriptname && $process->pid != $$ && $process->state ne 'defunct');
   }
   return;
}

my $iconswitcher;
my $blinktimer;
my $countdown;

my $cmd   = '/home/dimon/irssi-notify/irssi-tray-stop.sh';
my $icon1 = '/home/dimon/irssi-notify/icons/blink1-12x12.xpm';
my $icon2 = '/home/dimon/irssi-notify/icons/blink2-12x12.xpm';

Gtk2->init;

my $icon     = Gtk2::TrayIcon->new('tray');
my $eventbox = Gtk2::EventBox->new;
my $img      = Gtk2::Image->new_from_file($icon1);

$eventbox->add($img);
$icon->add($eventbox);
$icon->show_all;

$blinktimer = Glib::Timeout->add(650 => \&switch_icon);
$eventbox->signal_connect('button-press-event' => sub{system($cmd, $$)});

sub switch_icon
{
   if ($iconswitcher) {$img->set_from_file($icon1)}
   else               {$img->set_from_file($icon2)};
   $iconswitcher = !$iconswitcher;

   Gtk2->main_quit if ($countdown && --$countdown == 0);
   return 1;
}

sub blink_close
{
   # Stop the old timer
   Glib::Source->remove($blinktimer);
   # Start new with lower interval
   Glib::Timeout->add(100 => \&switch_icon);
# Blink 4 times
$countdown = 4;
}

$SIG{'USR1'} = 'blink_close';

Gtk2->main;


