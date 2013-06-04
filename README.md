Bloomd-Client
=============

This is a Perl client for the [bloomd server](https://github.com/armon/bloomd).

Installation
------------

Basic installation

``` perl Makefile.PL
make
make install
```

This distribution uses [DistZilla](http://dzil.org/), so you can use the dzil commands as well.

If you want to run the tests, you'll need a bloomd server up and running, and
you'll need to set BLOOMD_HOST and BLOOMD_PORT:

```
BLOOMD_HOST=127.0.0.1 BLOOMD_PORT=8673 make test
```

Usage
-----

All the commands from bloomd
[protocol](https://github.com/armon/bloomd#protocol) are wrapped in a method
with the same name. Return values are converted to Perl types (e.g. `1`/`<empty
string>` instead of `Yes`/`No`)

``` use Bloomd::Client;
my $b = Bloomd::Client->new;
my $filter = 'test_filter';
$b->create($filter);
my $array_ref = $b->list();
my $hash_ref = $b->info($filter);
$b->set($filter, 'u1');
$b->check($filter, 'u1');
my $hashref = $b->multi( $filter, qw(u1 u2 u3) );
```

Timeout support
---------------

You can set the timeout option to the constructor. The timeout will be on
reading and on writing the socket.

More doc
--------

Check on metacpan
