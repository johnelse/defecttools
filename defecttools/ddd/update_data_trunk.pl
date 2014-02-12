#!/usr/bin/perl -wl
use strict;
use DBI;

# In Debug mode, diagnostics are written to stderr and the results are written to stdout.
# In normal mode, there are no diagnostics and the results are written to the database.

my $DEBUG = 0;

# Set up

my $dbfile = "/home/ring3defects/data/defect_dashboard/tickets_trunk.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=".$dbfile, '', '');

# Fetch data

# Normally we do the last run in the db, but if an argument is passed in, that is used instead
my $max_run = $dbh->selectrow_arrayref("SELECT MAX(id) FROM runs")->[0];
my $run = shift;
die "Invalid argument; run must be >= 2 and <= max in db" if (defined $run && ($run < 2 || $run > $max_run));
$run = $max_run if !defined($run);

my $fetch = $dbh->prepare("SELECT * FROM observations WHERE run = ?");
my $new_obs = $dbh->selectall_arrayref($fetch, { Slice => {} }, $run);  # arrayref of hashrefs
my $old_obs = $dbh->selectall_arrayref($fetch, { Slice => {} }, $run - 1);

# For each ticket in the new list, we're going to want to go through the old tickets to see where it came from;
# and conversely, for each ticket in the old list, the new tickets to see where it went to. To avoid this being
# an O(n^2) operation, we're now going to construct a hash table indexed by ticket id. Unfortunately we can't ask
# the database to do this for us because a ticket can be in several filters and so occur more than once. For the
# same reason, the values in the hash table are going to be arrayrefs of observations (where an observation is a
# hashref).

sub populate_hash
{
    my ($arrref, $hashref) = @_;
    foreach (@$arrref) {
	my $ticket = $_->{ticket};
	$$hashref{$ticket} = [] if (!defined($$hashref{$ticket}));
	push $$hashref{$ticket}, $_;
    }
}
my (%new_obs, %old_obs);
populate_hash($new_obs, \%new_obs);
populate_hash($old_obs, \%old_obs);

# Now iterate over the array tickets, maintaining several counters for each (filter, priority) pair.

sub compare_lists {
    my ($current_array, $old_hash, $counts) = @_;

    for (@$current_array) {
	my $filter_id = $_->{filter_id};
	next if $filter_id == 0;  # 0 is a special filter for recently resolved tickets
	next if $_->{status} eq 'Staging';  # Staging is also regarded as resolved
	my $priority = $_->{priority};

	# Total number
	increment($counts, 'total', $filter_id, $priority);

	# Try to find where it came from
	my $ticket = $_->{ticket};
	my $from = $$old_hash{$ticket};
	if (!defined $from) {
	    increment($counts, 'new', $filter_id, $priority);
	} else {
	    # We need to allow for several of the following to be possibly true, if a ticket occurs more than once
	    my $unchanged = 0;
	    my $reprioritise = 0;
	    my $other_team = 0;
	    my $fixed = 0;
	    my $resolution = 0;
	    foreach my $obs (@$from) {
		if ($obs->{status} eq 'Staging') { $fixed = 1 }
		elsif ($obs->{filter_id} == $filter_id && $obs->{priority} eq $priority) { $unchanged = 1 }
		elsif ($obs->{filter_id} == $filter_id) { $reprioritise = 1 }
		elsif ($obs->{filter_id} != 0) { $other_team = 1 }
		elsif ($obs->{resolution} eq 'Fixed') { $fixed = 1 }
		else { $resolution = 1 }
	    }
	    if (!$unchanged) {
		if ($reprioritise) {
		    increment($counts, 'reprioritised', $filter_id, $priority);
		    print STDERR "$ticket was reprioritised" if $DEBUG;
		} elsif ($other_team) {
		    increment($counts, 'other_team', $filter_id, $priority);
		    print STDERR "$ticket changed teams" if $DEBUG;
		} else {
		    increment($counts, 'resolved', $filter_id, $priority);
		    if ($fixed) {
			increment($counts, 'fixed', $filter_id, $priority);
			print STDERR "$ticket was fixed" if $DEBUG;
		    } else {
			increment($counts, 'other_resolution', $filter_id, $priority);
			print STDERR "$ticket was resolved some other way" if $DEBUG;
		    }
		}
	    }
	}
    }
}

# Compare current tickets against the previous set
my $all_counts = {};
my $counts1 = {};
compare_lists($new_obs, \%old_obs, $counts1);
$all_counts->{total} = $counts1->{total};
$all_counts->{new} = $counts1->{new};
$all_counts->{from_reprioritised} = $counts1->{reprioritised};
$all_counts->{from_other_team} = $counts1->{other_team};
$all_counts->{from_unresolving} = $counts1->{resolved};

# And compare previous tickets against the new set
my $counts2 = {};
compare_lists($old_obs, \%new_obs, $counts2);
$all_counts->{old_total} = $counts2->{total};
$all_counts->{disappeared} = $counts2->{new};
$all_counts->{to_reprioritised} = $counts2->{reprioritised};
$all_counts->{to_other_team} = $counts2->{other_team};
$all_counts->{fixed} = $counts2->{fixed};
$all_counts->{other_resolution} = $counts2->{other_resolution};

# Iterate over filters (= teams) and priorities, and write out the results

my $max_filter = $dbh->selectrow_arrayref("SELECT MAX(id) FROM filters")->[0];
my $priorities = $dbh->selectall_arrayref("SELECT DISTINCT priority FROM observations");
my @priorities = map { $_->[0] } @$priorities;

my $insert;
$insert = $dbh->prepare("INSERT INTO changes VALUES(".(join ',', (('?')x13)).")") if !$DEBUG;

foreach my $filter_id (1..$max_filter) {
    foreach my $priority (@priorities) {
	my @data = ($run, $filter_id, $priority,
		    get_value($all_counts, 'total', $filter_id, $priority),
		    get_value($all_counts, 'new', $filter_id, $priority),
		    get_value($all_counts, 'from_reprioritised', $filter_id, $priority),
		    get_value($all_counts, 'from_other_team', $filter_id, $priority),
		    get_value($all_counts, 'from_unresolving', $filter_id, $priority),
		    get_value($all_counts, 'disappeared', $filter_id, $priority),
		    get_value($all_counts, 'to_reprioritised', $filter_id, $priority),
		    get_value($all_counts, 'to_other_team', $filter_id, $priority),
		    get_value($all_counts, 'fixed', $filter_id, $priority),
		    get_value($all_counts, 'other_resolution', $filter_id, $priority));
	if ($DEBUG) {
	    # Sanity check
	    die "Wrong at $filter_id $priority" unless
		$data[3] == get_value($all_counts, 'old_total', $filter_id, $priority) +
		            $data[4] + $data[5] + $data[6] + $data[7] - $data[8] - $data[9] - $data[10] - $data[11] - $data[12];
	    print(join '|', @data);
	} else {
	    $insert->execute(@data) or die "Failed to insert data";
	}
    }
}

# Clean up

$dbh->disconnect;

# That's the end of the program. Finally some utility functions to set and retrieve values from multidimensional hash tables.

sub increment {
    my ($counts, $metric, $filter_id, $priority) = @_;
    $counts->{$metric} = {} if !defined($counts->{$metric});
    $counts->{$metric}->{$filter_id} = {} if !defined($counts->{$metric}->{$filter_id});
    $counts->{$metric}->{$filter_id}->{$priority} = 0 if !defined($counts->{$metric}->{$filter_id}->{$priority});
    $counts->{$metric}->{$filter_id}->{$priority}++;
}

sub get_value {
    my ($counts, $metric, $filter_id, $priority) = @_;
    if (defined($counts->{$metric}) &&
	defined($counts->{$metric}->{$filter_id}) &&
	defined($counts->{$metric}->{$filter_id}->{$priority})) {
	return $counts->{$metric}->{$filter_id}->{$priority};
    } else { return 0 }
}
