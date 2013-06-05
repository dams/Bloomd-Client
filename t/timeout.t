#!perl

use feature ':5.12';

BEGIN {
    unless ( $ENV{BLOOMD_HOST} && $ENV{BLOOMD_PORT} ) {
        require Test::More;
        Test::More::plan(
            skip_all => 'variable BLOOMD_HOST and BLOOMD_PORT should be defined to test against a real bloomd server' );
    }
}

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::More;
use Test::Exception;
use Test::TCP;
use autobox::Core;
use POSIX qw(ETIMEDOUT ECONNRESET strerror);
use Bloomd::Client;

sub create_server_with_timeout {
    my $in_timeout = shift;

    Test::TCP->new(
        code => sub {
            my $port   = shift;
            my $socket = IO::Socket::INET->new(
                Listen    => 5,
                Timeout   => 1,
                Reuse     => 1,
                Blocking  => 1,
                LocalPort => $port
            ) or die "ops $!";

            my $buffer;
            while (1) {
                my $client = $socket->accept();

                if ( my $line = $client->getline() ) {
                    $line = $line->trim("\r\n");
#                    say STDERR " --- DEBUG line [$line]";
                    if ($in_timeout && $line ne 'info foo' ) {
                        sleep($in_timeout);
                    }

                    # When the client has a timeout, it'll never consume this
                    # print, until the Timeout of the IO::Socket::INET
                    $client->print('foo bar');
                }

                $client->close();
            }
        },
    );
}

my $server = create_server_with_timeout(2);

my $b = Bloomd::Client->new(
    host             => '127.0.0.1',
    port             => $server->port,
    timeout          => 1,
);

ok $b, 'client created';

my $etimeout = strerror(ETIMEDOUT);

throws_ok { $b->list() } qr/$etimeout/, "got timeout croak";

# now reissue an other command on the same object, which will not timeout. We
# check that the socket is properly recreated.

lives_ok {
    is_deeply $b->info('foo'), { foo => 'bar'}, "fake info returns proper results";
}, "doesn't die without timeout";

done_testing;
