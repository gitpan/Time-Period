# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use Time::Local;
BEGIN { plan tests => 6 };
use Time::Period ':constants';
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $time = timelocal(0, 0, 0, 7, 8, 2002);

my $day = '1y 2m 3w 8d 24H 30M';

ok(ref $day eq 'Time::Period');

ok("$day" eq '1y, 2m, 4w, 2d, 30M');

ok(localtime($time + '1y 2m') eq 'Fri Nov  7 00:00:00 2003');

my $test = "1y" + "2w";
ok("$test" eq '1y, 2w');

ok(localtime($time - '1y') eq 'Fri Sep  7 00:00:00 2001');

