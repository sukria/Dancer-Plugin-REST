package TestUtils;

use base 'Exporter';
use vars '@EXPORT';

use File::Path qw(mkpath rmtree);
use Dancer::Request;
use Dancer::Config 'setting';

@EXPORT =
  qw(fake_request get_response_for_request);

sub fake_request($$;$) {
    my ($method, $path, $params) = @_;
    my $req = Dancer::Request->new_for_request($method => $path);
    if ($params) {
       $req->_set_body_params($params); 
    }
    return $req;
}

sub get_response_for_request {
    my ($method, $path, $params) = @_;
    my $request = fake_request($method => $path, $params);
    Dancer::SharedData->request($request);
    Dancer::Renderer::get_action_response();
}

1;
