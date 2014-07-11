
use strict;
use warnings;

use FindBin '$Bin';
use Test::More;

use lib "$Bin/../../lib";

use Raisin::Routes;
use Raisin::Routes::Endpoint;
use Types::Standard qw(Str);

my $r = Raisin::Routes->new;

#
# TODO:
#
#   get sub {};
#   get '/foo' => sub {};
#   params [...], get => sub {};
#   params [...], get '/bar' => sub {};
#

ok $r->add(POST => '/dump/:id', sub {'DUMP'}), 'add /dump/:id';
ok $r->add(POST => '/dump', sub {'DUMP'}), 'add /dump';
ok $r->add(
        POST   => '/person(?<format>\.\w+)?',
        params => [
            requires => { name => 'name',  type => Str },
            optional => { name => 'email', type => Str }
        ],
        sub { 'PERSON' }
    ),
    'add /person(?<format>)';

is $r->list->{POST}{'/person(?<format>\.\w+)?'}, 3, 'check order in routes list';
is_deeply $r->cache, {}, 'clear cache';

my $subs;
subtest 'find' => sub {
    ok $subs = $r->find('POST', '/person'), 'without extension';
    ok $subs = $r->find('POST', '/person.json'), 'with extension';
};

is $subs->[0]->code->(), 'PERSON', 'execute found route';
is ref $r->cache->{'post:/person'}, 'ARRAY', 'check cache';

done_testing;
