use strict;
use warnings;
use Dancer::ModuleLoader;
use Test::More import => ['!pass'];

plan skip_all => "JSON is needed for this test"
    unless Dancer::ModuleLoader->load('JSON');
plan skip_all => "YAML is needed for this test"
    unless Dancer::ModuleLoader->load('YAML');

my $data = { foo => 42 };
my $json = JSON::encode_json($data);
my $yaml = YAML::Dump($data);

{
    package Webservice;
    use Dancer;
    use Dancer::Plugin::REST;

    setting plugins => {
        REST => {
            serializers => {
                'yaml' => 'YAML',
                'json' => 'NotExists',
            }
        }
    };

    prepare_serializer_for_format;

    get '/' => sub { "root" };
    get '/:something.:format' => sub {
        $data;
    };
}

use lib 't';
use TestUtils;

my @tests = (
    {
        request => [GET => '/'],
        response => 'root',
    },
    { 
        request => [GET => '/foo.json'],
        response => qr/An internal error occured/ms
    },
    { 
        request => [GET => '/foo.yaml'],
        response => $yaml,
    },
    { 
        request => [GET => '/foo.foobar'],
        response => qr/unsupported format requested: foobar/ms,
    },
    {
        request => [GET => '/'],
        response => 'root',
    },
);

plan tests => scalar(@tests);

for my $test ( @tests ) {
    my $response = get_response_for_request(@{$test->{request}});
    if (ref($test->{response})) {
        like( $response->{content}, $test->{response},
            "response looks good for '@{$test->{request}}'" );
    }
    else {
        is( $response->{content}, $test->{response},
            "response looks good for '@{$test->{request}}'" );
    }
}



