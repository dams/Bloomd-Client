Bloomd-Client
=============

This is a Perl client for the [bloomd server](https://github.com/armon/bloomd).

Installation
------------

Basic installation

This distribution is on CPAN, so you might want to use your preferred CPAN
client to install it:

```
# using cpanminus
cpanm Bloomd::Client

# using regular cpan
cpan Bloom::Client
```

If you'd like to install it from the source, see the last section of this file

Usage
-----

All the commands from bloomd
[protocol](https://github.com/armon/bloomd#protocol) are wrapped in a method
with the same name. Return values are converted to Perl types (e.g. `1`/`<empty
string>` instead of `Yes`/`No`)

```
use feature ':5.12';
use Bloomd::Client;
my $b = Bloomd::Client->new;
my $filter = 'test_filter';
$b->create($filter);
my $array_ref = $b->list();
my $hash_ref = $b->info($filter);
$b->set($filter, 'u1');
if ($b->check($filter, 'u1')) { say "it exists!" }
my $hashref = $b->multi( $filter, qw(u1 u2 u3) );
```

Timeout support
---------------

You can set the timeout option to the constructor. The timeout will be on
reading and on writing to the socket. It can be a float, up to microseconds.

More doc
--------

Check on metacpan

Build from the source
---------------------

This distribution uses [DistZilla](http://dzil.org/), so you should first
install `Dist::Zilla` ( with `cpan Dist::Zilla` or using `cpanm`). Then:

```
dzil authordeps --missing | cpan
dzil listdeps --missing | cpan
dzil build
```

If you want to run the tests, you'll need a bloomd server up and running, and
you'll need to set BLOOMD_HOST and BLOOMD_PORT:

```
BLOOMD_HOST=127.0.0.1 BLOOMD_PORT=8673 dzil test
```
