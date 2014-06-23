package SocketIO::Emitter;
use strict;
use warnings;
our $VERSION = 0.01;

use Redis;
use Data::MessagePack;

use Moo;
use namespace::clean;

has redis => ( is => 'rw');
has key   => ( is => 'rw');
has rooms => ( is => 'rw', default => sub {[]} );
has flags => ( is => 'rw', default => sub {{}} );
has messagepack => ( is => 'rw', default => sub { Data::MessagePack->new() } );

my $EVENT = 2;
my $BINARY_EVENT = 5;

sub BUILD {
     my $self = shift;
     # redis
     my $redis = $self->redis || Redis->new();
     $self->redis($redis);
     # key
     my $key = (($self->key) ? $self->key : 'socket.io') . '#emitter';
     $self->key($key);
}

sub json      { $_[0]->flags->{json}      = 1; $_[0]; }
sub volatile  { $_[0]->flags->{volatile}  = 1; $_[0]; }
sub broadcast { $_[0]->flags->{broadcast} = 1; $_[0]; }

sub in {
    my ($self, $room) = @_;
    push $self->rooms, $room
        unless grep { $_ eq $room } @{$self->rooms};
    $self;
}

sub to {
    my ($self, $room) = @_;
    $self->in($room);
    $self;
}

sub of {
    my ($self, $nsp) = @_;
    $self->flags->{nsp} = $nsp;
    $self;
}

sub emit {
    my ($self, @args) = @_;

    my %packet;
    $packet{type} = ($self->include_binary(@args)) ? $BINARY_EVENT : $EVENT;
    $packet{data} = \@args;
    $packet{nsp}  = '/';

    if(grep {$_ eq 'nsp'} keys $self->flags) {
      $packet{'nsp'} = $self->flags->{'nsp'};
      delete $self->flags->{'nsp'};
    }

    my $packed = $self->messagepack->pack([\%packet, { rooms => $self->rooms, flags => $self->flags }]);
    $self->redis->publish($self->key, $packed);

    # clear
    $self->rooms([]);
    $self->flags({});

    $self;
}

sub include_binary {
    my ($self, @args) = @_;
    for(@args) {
        return 1 if /[[:^ascii:]]/;
    }
    return;
}

1;

__END__

=encoding utf-8

=head1 NAME

SocketIO::Emitter - A Perl implementation of socket.io-emitter.

=head1 SYNOPSIS

    use strict;
    use warnings;
    use SocketIO::Emitter;

    my $em = SocketIO::Emitter->new(
      #  key => 'another-key',
      #  redis => Redis->new(server => 'localhost:6380'),
    );

    # emit
    $em->emit('event', 'broadcast blah blah blah');

    # namespace emit
    $em->of('/nsp')->emit('event', 'nsp broadcast blah blah blah');

    # namespace room broadcast
    $em->of('/nsp')->room('roomId')->broadcast->emit('event', 'yahooooooo!!!!');


=head1 DESCRIPTION

A Perl implementation of socket.io-emitter.

This project uses redis. Make sure your environment has redis.


=head1 LICENSE

Copyright (C) Tsuyoshi Torii

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Tsuyoshi Torii E<lt>toritori0318@gmail.comE<gt>

=cut
