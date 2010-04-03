package TestUtils;

use base 'Exporter';
use vars '@EXPORT';

use File::Path qw(mkpath rmtree);
use Dancer::Request;
use Dancer::Config 'setting';

@EXPORT =
  qw(fake_request get_response_for_request);

sub fake_request($$) {
    my ($method, $path) = @_;
    return Dancer::Request->new_for_request($method => $path);
}

sub get_response_for_request {
    my ($method, $path) = @_;
    my $request = fake_request($method => $path);
    Dancer::SharedData->request($request);
    Dancer::Renderer::get_action_response();
}

1;
