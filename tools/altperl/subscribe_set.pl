#!@@PERL@@
# $Id: subscribe_set.pl,v 1.9 2005-02-22 17:11:18 smsimms Exp $
# Author: Christopher Browne
# Copyright 2004 Afilias Canada

use Getopt::Long;

# Defaults
$CONFIG_FILE = '@@SYSCONFDIR@@/slon_tools.conf';
$SHOW_USAGE  = 0;

# Read command-line options
GetOptions("config=s"  => \$CONFIG_FILE,
	   "help"      => \$SHOW_USAGE);

my $USAGE =
"Usage: subscribe_set [--config file] set# node#

    Begins replicating a set to the specified node.

";

if ($SHOW_USAGE) {
  print $USAGE;
  exit 0;
}

require '@@PGLIBDIR@@/slon-tools.pm';
require $CONFIG_FILE;

my ($set, $node) = @ARGV;
if ($node =~ /^(?:node)?(\d+)$/) {
  $node = $1;
} else {
  print "Need to specify node!\n";
  die $USAGE;
}

if ($set =~ /^(?:set)?(\d+)$/) {
  $set = $1;
} else {
  print "Need to specify set!\n";
  die $USAGE;
}

$FILE="/tmp/slonik-subscribe.$$";
open(SLONIK, ">$FILE");
print SLONIK genheader();
print SLONIK "  try {\n";

if ($DSN[$node]) {
  my $parent = 1;
  my $forward;
  if ($PARENT[$node]) {
    $parent = $PARENT[$node];
  }
  if ($NOFORWARD[$node] eq "yes") {
    $forward = "no";
  } else {
    $forward = "yes";
  }
  print SLONIK "    subscribe set (id = $set, provider = $parent, receiver = $node, forward = $forward);\n";
} else {
  die "Node $node not found\n";
}

print SLONIK "  }\n";
print SLONIK "  on error {\n";
print SLONIK "    exit 1;\n";
print SLONIK "  }\n";
print SLONIK "  echo 'Subscribed nodes to set $set';\n";
close SLONIK;
run_slonik_script($FILE);
