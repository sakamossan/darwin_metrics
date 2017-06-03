#!/usr/bin/perl
use strict;
use warnings;
use JSON 'encode_json';
use constant MB => 1024 ** 2;

# stole from https://github.com/mackerelio/mackerel-agent/tree/master/metrics/darwin

sub usage {
    print "usage: ./darwin_metrics.pl (memory|cpuusage)\n";
    exit 1;
}

sub memory {
    my %vm_stat = do {
        open my $out, 'vm_stat |';
        my ($page_size) = (<$out> =~ /page size of (\d+) bytes/);
        map {
            my ($name, $value) = /^(.+?):\s+(\d+)/;
            ($name => int ($page_size * $value / MB));
        } <$out>;
    };

    my $cached = $vm_stat{'Pages purgeable'} + $vm_stat{'File-backed pages'};
    my $free = $vm_stat{"Pages free"};
    my $used = $vm_stat{'Pages wired down'}
        + $vm_stat{'Pages occupied by compressor'}
        + $vm_stat{'Pages active'}
        + $vm_stat{'Pages inactive'}
        + $vm_stat{'Pages speculative'}
        - $cached;
    my $total = $used + $cached + $free;

    return {
        total => $total,
        used => $used,
        cached => $cached,
        free => $free,
        %{ _swap() }
    };
}

sub _swap {
    my ($total, $used, $free) = map { int }
        (`sysctl vm.swapusage` =~ /total = (\d+).+? used = (\d+).+? free = (\d+)/);
    return {
        swap_total => $total,
        swap_used => $used,
        swap_free => $free,
    };
}

sub cpuusage {
    open my $out, 'iostat -n0 -c2 |';
    readline $out;  # discard
    my @names = grep { $_ } split /\s+/, readline $out;
    my @values = grep { length $_ } split /\s+/, readline $out;
    my %ret;
    @ret{@names} = map {$_ + 0} @values;
    \%ret;
}

# main
my $arg = shift or usage();
print encode_json (
    $arg eq 'memory'   ? memory() :
    $arg eq 'cpuusage' ? cpuusage() :
    usage()
);
