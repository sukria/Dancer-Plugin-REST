use strict;
use warnings;
use Dancer::ModuleLoader;
use Test::More import => ['!pass'];

plan skip_all => "JSON is needed for this test"
    unless Dancer::ModuleLoader->load('JSON');
plan tests => 3;

my $data = { foo => 42 };
my $json = JSON::encode_json($data);

{
    package Webservice;
    use Dancer;
    use Dancer::Plugin::REST;

    prepare_serializer_for_format;

    get '/foo.:format' => sub {
        $data;
    };
}

use lib 't';
use TestUtils;

my $response = get_response_for_request(GET => '/foo.json');
ok(defined($response), "response found for /foo.json");

is_deeply( $response->{headers}, [ 'Content-Type' => 'application/json'],
    "headers have content_type set to application/json" );

is( $response->{content}, $json,
    "\$data has been encoded to JSON");
