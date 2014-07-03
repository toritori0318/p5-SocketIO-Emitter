use strict;
use warnings;
use SocketIO::Emitter;
use Test::More;


my $ioe = SocketIO::Emitter->new();
# basic
{
    is_deeply(
        $ioe->pack('event', 'event message'),
        [
            {
                'data' => [
                    'event',
                    'event message'
                ],
                'type' => 2,
                'nsp' => '/'
            },
            {
              'rooms' => [],
              'flags' => {}
            }
        ]
    );
    $ioe->clear;
}

# namespace
{
    is_deeply(
        $ioe->of('/nsp')->pack('event nsp', 'event nsp message'),
        [
            {
                'data' => [
                    'event nsp',
                    'event nsp message'
                ],
                'type' => 2,
                'nsp' => '/nsp'
            },
            {
              'rooms' => [],
              'flags' => {}
            }
        ]
    );
    $ioe->clear;
}

# namespace + room
{
    is_deeply(
        $ioe->of('/nsp')->to('some room')->pack('event nsp room', 'event nsp room message'),
        [
            {
                'data' => [
                    'event nsp room',
                    'event nsp room message'
                ],
                'type' => 2,
                'nsp' => '/nsp'
            },
            {
              'rooms' => ['some room'],
              'flags' => {}
            }
        ]
    );
    $ioe->clear;
}

# broadcast
{
    is_deeply(
        $ioe->broadcast->pack('event broadcast', 'event broadcast message'),
        [
            {
                'data' => [
                    'event broadcast',
                    'event broadcast message'
                ],
                'type' => 2,
                'nsp' => '/'
            },
            {
              'rooms' => [],
              'flags' => {
                  'broadcast' => 1,
              }
            }
        ]
    );
    $ioe->clear;
}

# volatile
{
    is_deeply(
        $ioe->volatile->pack('event volatile', 'event volatile message'),
        [
            {
                'data' => [
                    'event volatile',
                    'event volatile message'
                ],
                'type' => 2,
                'nsp' => '/'
            },
            {
              'rooms' => [],
              'flags' => {
                  'volatile' => 1,
              }
            }
        ]
    );
    $ioe->clear;
}

# json
{
    is_deeply(
        $ioe->json->pack('event json', 'event json message'),
        [
            {
                'data' => [
                    'event json',
                    'event json message'
                ],
                'type' => 2,
                'nsp' => '/'
            },
            {
              'rooms' => [],
              'flags' => {
                  'json' => 1,
              }
            }
        ]
    );
    $ioe->clear;
}

# binary
{
    my $bin = pack("CCC", 65, 66, 67);
    print Dumper $bin;
    is_deeply(
        $ioe->pack('event binary', $bin),
        [
            {
                'data' => [
                    'event binary',
                    'あいうえお'
                ],
                'type' => 2,
                'nsp' => '/'
            },
            {
              'rooms' => [],
              'flags' => {}
            }
        ]
    );
    $ioe->clear;
}

done_testing;
