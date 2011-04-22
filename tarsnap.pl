#!/usr/bin/perl
# Author: Nolan Caudill
# Date: 2011-04-21

use strict;
use warnings;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

my $today = sprintf('%04s-%02s-%02s', $year+1900, $mon+1, $mday);

print "Starting backup for $today\n===========\n";

# Config for backups (hyphens are important)
# Backups will be stored in format "$archive-$date"
my %backups  = (
    'projects' => {
        'dir' => join('/', $ENV{HOME}, 'projects'),
        'num' => 3,
    },
    'images' => {
        'dir' => join('/', $ENV{HOME}, 'images')',
        'num' => 3,
    }
);

# Fetch current backups
my @archives = split("\n", `tarsnap --list-archives`);

# Get list of backups for this machine
my %curr_backups;
foreach (sort @archives) {
    (my $archive, my $junk) = split("-", $_);

    if ($backups{$archive}) {
        print "Saw previous backup called \"$_\"\n";
        push @{$curr_backups{$archive}}, $_;
    }
}

# Delete old backups
foreach my $archive (keys %curr_backups) {
    my $num_backups = @{$curr_backups{$archive}};
    my $req_backups = $backups{$archive}{'num'};

    while ($num_backups >= $req_backups) {
        my $backup = shift @{$curr_backups{$archive}};
        print "Deleting $backup\n";
        `tarsnap -d -f $backup`;
        $num_backups--;
    }
}

# Create today's backups
foreach my $archive (keys %backups) {
    my $dir = $backups{$archive}{'dir'};
    my $backup_name = "$archive-$today";

    print "Creating archive $backup_name\n";
    `tarsnap -c -f $backup_name $dir`;
}

print "###############\n";

