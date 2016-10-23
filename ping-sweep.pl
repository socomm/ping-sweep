#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

use Net::Ping;
use Parallel::ForkManager;
use Net::Address::IP::Local;

use constant {
    DEBUG => 0,
    MAX_PROCS => 50,
    DURATION => 1,
};

my $ping = Net::Ping->new();
my $proc = Parallel::ForkManager->new( MAX_PROCS );
my $net = shift // Net::Address::IP::Local->public;  
$net =~ s/^((\d{1,3}\.){3})\d+$/${1}/; 

sub ping_sweep {
    DATA_LOOP:
    foreach my $host ( 1..254 ){
        my $pid = $proc->start and next DATA_LOOP;
        my $dest = $net.$host;
        say "pinging:\t$dest" if DEBUG;
        say "$net$host is pingable." if $ping->ping( $dest, DURATION );
        $proc->finish;
    }
    $proc->wait_all_children;
}

ping_sweep;
