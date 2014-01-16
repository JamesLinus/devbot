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

use strict;
use warnings;

use lib '../lib';

use Cwd;
use Test::More tests => 7;
use Test::Class::Load '../t';

$DevBot::Utils::ROOT_DIR = substr(getcwd, 0, rindex(getcwd, '/'));

diag('Root directory = ' . $DevBot::Utils::ROOT_DIR);	

Test::Class->runtests();
