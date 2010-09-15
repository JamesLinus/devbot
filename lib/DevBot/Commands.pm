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

package DevBot::Commands;

use strict;
use warnings;

use DevBot::DB;
use DevBot::Config;
use DevBot::Queries;

our $VERSION = 1.00;

#
#
#
sub command_history
{
	my ($channel, $history) = @_;
	
	return undef if (!$history);
				
	my $result = query($DevBot::Queries::HISTORY_QUERY, $channel, $history);
	
	my @messages = ();
	
	while (my @row = $result->fetchrow_array)
	{
		push(@messages, printf("[%s] <%s> %s\n", $row[0], $row[1], $row[2]));
	}
	
	return @messages;
}

#
#
#
sub command_issue
{
 	
}

1;