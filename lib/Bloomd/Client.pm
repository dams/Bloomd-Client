package Bloomd::Client;

use 5.0101;
use Moo;
use Method::Signatures;
use autobox::Core;    
use List::MoreUtils qw(mesh);
use Carp;
use IO::Socket::INET;

has protocol => ( is => 'ro', default => sub {'tcp'} );
has host => ( is => 'ro', default => sub {'127.0.0.1'} );
has port => ( is => 'ro', default => sub {8673} );
has _socket => ( is => 'lazy', predicate => 1, clearer => 1 );
has timeout => ( is => 'ro', default => sub {10} );

method _build__socket {
    my $socket = IO::Socket::INET->new(
        Proto => $self->protocol,
        PeerHost => $self->host,
        PeerPort => $self->port,
        Timeout  => $self->timeout,
    ) or die "Can't connect to server: $!";
}

method disconnect {
    $self->_has_socket
      and $self->_socket->close;
    $self->_clear_socket;
}

method create ($name, $capacity?, $prob?, $in_memory?) {
    my $args =
        ( $capacity ? "capacity=$capacity" : '' )
      . ( $prob ? "prob=$prob" : '' )
      . ( $in_memory ? "in_memory=$in_memory" : '' );
    $self->_execute("create $name $args" ) eq 'Done';
}

method list ($prefix? = '') {
    my @keys = qw(name prob size capacity items);
    [
     map {
         my @values = split / /;
         +{ mesh @keys, @values };
     }
     $self->_execute("list $prefix" )
    ];
}

method drop ($name) {
    $self->_execute("drop $name") eq 'Done';
}


method close ($name) {
    $self->_execute("close $name") eq 'Done';
}

method clear ($name) {
    $self->_execute("clear $name") eq 'Done';
}

method check ($name, $key) {
    $self->_execute("c $name $key") eq 'Yes';
}

method multi ($name, @keys) {
    @keys
      or return {};
    my @values = map { $_ eq 'Yes' } split / /, $self->_execute("m $name @keys");
    +{mesh @keys, @values };
}

method set ($name, $key) {
    $self->_execute("s $name $key") eq 'Yes';
}

method bulk ($name, @keys) {
    @keys
      or return;
    $self->_execute("b $name @keys");
    return;
}

method info ($name) {
    +{ map { split / / } $self->_execute("info $name") };
}

method flush ($name) {
    $self->_execute("info $name") eq "Done";
}

method _execute ($command) {
     my $socket = $self->_socket;

     $socket->print($command . "\r\n")
       or croak "couldn't write to socket";

     my $line = $socket->getline()->rtrim("\r\n");
     $line =~ /^Client Error:/
       and croak "$line: $command";

     say "[$line]";
     $line eq 'START'
       or return $line;

     my @lines;
     push @lines, $line
       while (($line = $socket->getline->rtrim("\r\n")) ne 'END');
 
     say Dumper(\@lines); use Data::Dumper;
     return @lines;
}

1;
