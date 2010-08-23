#
#  $Id$
#  
#  devbot
#  http://dev.stuconnolly.com/svn/devbot/
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

package DevBot::Issues;

use strict;
use warnings;

use XML::RSS;
use XML::FeedPP;
use LWP::Simple;
use DevBot::Log;
use DevBot::Time;
use DevBot::Config;
use DateTime;
use DateTime::Format::W3CDTF;

use base 'Exporter';

our @EXPORT = qw(get_updated_issues);

our $VERSION = 1.00;

#
# Google Code hosting domain
#
our $GC_HOSTING_DOMAIN = 'code.google.com';

#
# Returns an array of updated issues via the project's issues Atom feed.
#
sub get_updated_issues
{
	my @issues = ();
	my $conf = get_config('gc');
	
	my $project = $conf->{GC_PROJECT};
	my $issue_url = $conf->{GC_ISSUE_URL};
	
	die 'No Google Code project name provided in Google Code config.' unless $project;
	
	my $url = "http://${GC_HOSTING_DOMAIN}/feeds/p/${project}/issueupdates/basic";
						
	log_m("Requesting: $url");
	
	my $feed = XML::FeedPP::Atom->new($url);
				
	my $w3c = DateTime::Format::W3CDTF->new;
	
	my $pub_date = $feed->pubDate();
	
	# Remove timezone indicator
	$pub_date =~ s/Z//g;
		
	my $cur_datetime = $w3c->parse_datetime(get_last_updated_datetime);	
	my $feed_datetime = $w3c->parse_datetime($pub_date);
	
	write_datetime($feed_datetime); 
	
	# Only continue if the feed's publication date is newer than the last time we check it
	if (DateTime->compare($feed_datetime, $cur_datetime) > 0) {
		
		foreach my $item ($feed->get_item()) 
		{	
			my $item_datetime = $w3c->parse_datetime($item->pubDate());	
			
			# Remove timezone indicator
			$item_datetime =~ s/Z//g;
			
			if (DateTime->compare($item_datetime, $cur_datetime) > 0) {

				my $issue_id = _extract_issue_id($item->link());

				my %issue = ('id'     => $issue_id,
							 'title'  => $item->title(),
							 'author' => $item->author(),
							 'url'    => _create_issue_url($project, $issue_url, $issue_id)
							);

				push(@issues, {%issue});
			}
		}
	}
	
	# Reverse the array so we report the updates in the order they occurred, 
	# not the order we encountered them.
	@issues = reverse(@issues);
	
	my $issue_count = @issues;
		
	log_m(sprintf('Found %d issue updates', $issue_count));
	
	return @issues;
}

#
# Extracts the issues ID from the supplied link.
#
sub _extract_issue_id
{
	my $issue_id  = 0; 
	my $issue_url = shift;
		
	($issue_url =~ /^http:\/\/${GC_HOSTING_DOMAIN}\/p\/[0-9a-z-]+\/issues\/detail\?id=([0-9]+)(?:#c[0-9]+)?$/) && ($issue_id = $1);
	
	return $issue_id;
}

#
# Creates the URL for the supplied issue details.
#
sub _create_issue_url
{
	my($project, $issue_tracker, $issue_id) = @_;
	
	return ($issue_tracker) ? sprintf($issue_tracker, $issue_id) : sprintf("http://${GC_HOSTING_DOMAIN}/p/%s/issues/detail?id=%d", $project, $issue_id);
}

1;