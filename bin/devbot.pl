#! /usr/bin/perl

#
#  devbot
#  https://github.com/stuconnolly/devbot
#
#  Copyright (c) 2010 Stuart Connolly. All rights reserved.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

package DevBotMain;

use strict;
use warnings;

use lib '../lib';

use Cwd;
use Carp;
use DevBot::Bot;
use DevBot::Time;
use DevBot::Utils;
use DevBot::Config;
use Getopt::Long;

my ($interactive,
	$commits,
	$issues,
	$message,
	$channel_logging,
	$logging,
	$log_dir,
	$version,
	$help);

# Get options
GetOptions('interactive|i'       => \$interactive,
		   'commits|c'           => \$commits,
		   'issues|g'            => \$issues,
		   'message|m'           => \$message,
		   'channel-logging|cl'  => \$channel_logging,
		   'logging|l'           => \$logging,
		   'logdir|d=s'          => \$log_dir,
		   'version|v'           => \$version,
		   'help|h'              => \$help);

# Decide what to do
DevBot::Utils::usage if $help;
DevBot::Utils::version if $version;

$DevBot::Log::LOGGING = 1 if $logging;
$DevBot::Log::LOG_PATH = $log_dir if $log_dir;

# Set the root dir
$DevBot::Utils::ROOT_DIR = substr(getcwd, 0, rindex(getcwd, '/'));

my $irc_conf = DevBot::Config::get('irc');

my $irc_nick     = $irc_conf->{IRC_NICK}   || 'devbot';
my $irc_server   = $irc_conf->{IRC_SERVER} || 'irc.freenode.net';
my $irc_port     = $irc_conf->{IRC_PORT}   || 6667;
my $irc_channels = [split(m/\s+/, $irc_conf->{IRC_CHANNEL})];

my $irc_message_key = $irc_conf->{IRC_MESSAGE_KEY};
my $irc_daemon_host = $irc_conf->{IRC_COMMIT_DAEMON_HOST} || 'localhost';
my $irc_daemon_port = $irc_conf->{IRC_COMMIT_DAEMON_PORT} || 1987;

my $proj_conf  = DevBot::Config::get('proj');

my $commit_key = $proj_conf->{COMMIT_KEY} || undef;
my $issue_update_tick = $proj_conf->{ISSUE_UPDATE_INTERVAL} || 300;

croak 'Issue or commit announcements enabled, but no project system specified in config (SYSTEM).' if (($issues || $commits) && !$proj_conf->{SYSTEM});
croak 'No IRC channel(s) provided in IRC config.' unless $irc_channels;

print "Enabling logging...\n" if $logging;
print "Enabling interactivity...\n" if $interactive;
print "Enabling issue announcements...\n" if $issues;
print "Enabling commit announcements...\n" if $commits;
print "Enabling the acceptance of incoming messages...\n" if $message;
print "Enabling channel logging...\n" if $channel_logging;

printf("Setting issue update check interval to %d seconds\n", $issue_update_tick) if $issues;

# Create the bot and run it
DevBot::Bot->new(
	server      => $irc_server,
	port        => $irc_port,
	channels    => $irc_channels,
	nick        => $irc_nick,
	alt_nicks   => ['devbot_', 'devbot__'],
	username    => 'devbot',
	name        => 'Development Bot',
	charset     => 'utf-8',

	interactive => $interactive,
	tick_int    => $issue_update_tick,
	daemon_host => $irc_daemon_host,
	daemon_port => $irc_daemon_port,
	commits     => $commits,
	issues      => $issues,
	message     => $message,
	logging     => $channel_logging,
	commit_key  => $commit_key,
	message_key => $irc_message_key
)->run();

# Get rid of the log
DevBot::Time::delete_datetime_log() if $issues;

exit 0;
