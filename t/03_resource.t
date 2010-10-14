use strict;
use warnings;
use Dancer::ModuleLoader;
use Test::More import => ['!pass'];

plan tests => 8;

{
    package Webservice;
    use Dancer;
    use Dancer::Plugin::REST;
    use Test::More import => ['!pass'];

    resource user => 
        'get' => \&on_get_user,
        'create' => \&on_create_user,
        'delete' => \&on_delete_user,
        'update' => \&on_update_user;

    my $users = {};
    my $last_id = 0;

    sub on_get_user {
        my $id = params->{'id'};
        { user => $users->{$id} };
    }

    sub on_create_user {
        my $id = ++$last_id;
        my $user = params('body');
        $user->{id} = $id;
        $users->{$id} = $user;

        { user => $users->{$id} };
    }

    sub on_delete_user {
        my $id = params->{'id'};
        my $deleted = $users->{$id};
        delete $users->{$id};
        { user => $deleted };
    }

    sub on_update_user {
        my $id = params->{'id'};
        my $user = $users->{$id};
        return { user => undef } unless defined $user;

        $users->{$id} = { %$user, %{params('body')} };
        { user => $users->{$id} };
    }

    eval { resource failure => get => sub { 'GET' } };
    like $@, qr{resource should be given with triggers}, 
        "resource must have 4 hooks";
}

use lib 't';
use TestUtils;

my $r = get_response_for_request(GET => '/user/1');
is_deeply $r->{content}, {user => undef},
    "user 1 is not defined";

$r = get_response_for_request(POST => '/user', { name => 'Alexis' });
is_deeply $r->{content}, { user => { id => 1, name => "Alexis" } },
    "create user works";

$r = get_response_for_request(GET => '/user/1');
is_deeply $r->{content}, {user => { id => 1, name => 'Alexis'}},
    "user 1 is defined";

$r = get_response_for_request(PUT => '/user/1', { nick => 'sukria', name =>
'Alexis Sukrieh' });
is_deeply $r->{content}, {user => { id => 1, name => 'Alexis Sukrieh', nick => 'sukria'}},
    "user 1 is updated";

$r = get_response_for_request(DELETE => '/user/1');
is_deeply $r->{content}, {user => { id => 1, name => 'Alexis Sukrieh', nick => 'sukria'}},
    "user 1 is deleted";

$r = get_response_for_request(GET => '/user/1');
is_deeply $r->{content}, {user => undef},
    "user 1 is not defined";

$r = get_response_for_request(POST => '/user', { name => 'Franck Cuny' });
is_deeply $r->{content}, { user => { id => 2, name => "Franck Cuny" } },
    "id is correctly increased";

