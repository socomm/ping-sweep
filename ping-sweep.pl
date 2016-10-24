#!/usr/bin/env perl
#------------------------------------------------------------------------------
# Copright (C) 2016 Juan Espinoza. All right reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, 
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, 
#    this list of conditions and the following disclaimer in the documentation 
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY 
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY 
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#-------------------------------------------------------------------------------
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
# Try to guess users network, if none is specified.
my $net = shift // Net::Address::IP::Local->public;
# Drop the last octet.  
$net =~ s/^((\d{1,3}\.){3})\d+$/${1}/; 

sub ping_sweep {
    DATA_LOOP:
    foreach my $host ( 1..254 ){
        my $pid = $proc->start and next DATA_LOOP;
        my $dest = $net.$host;
        # Be more verbose if DEBUG is set to non-zero.
        say "pinging:\t$dest" if DEBUG;
        say "$net$host is pingable." if $ping->ping( $dest, DURATION );
        $proc->finish;
    }
    $proc->wait_all_children;
}

ping_sweep;
# 53656520796F7520537061636520436F77626F79210A
