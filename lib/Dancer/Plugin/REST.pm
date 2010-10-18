package Dancer::Plugin::REST;
use Dancer ':syntax';
use Dancer::Plugin;

our $AUTHORITY = 'SUKRIA';
our $VERSION = '0.03';

register prepare_serializer_for_format =>
sub {
    my $conf        = plugin_setting;
    my $serializers = (
        ( $conf && exists $conf->{serializers} )
        ? $conf->{serializers}
        : {
            'json' => 'JSON',
            'yml'  => 'YAML',
            'xml'  => 'XML',
            'dump' => 'Dumper',
        }
    );

    before sub {
        my $format = params->{'format'};
        return unless defined $format;
        
        my $serializer = $serializers->{$format};
        unless (defined $serializer) {
            return halt(Dancer::Error->new(
                code => 404,
                message => "unsupported format requested: ".$format));
        }

        set serializer => $serializer;
    };
};

register resource =>
sub {
    my ($resource, %triggers) = @_;

    die "resource should be given with triggers"
        unless defined $resource and
            defined $triggers{get} and
            defined $triggers{update} and
            defined $triggers{delete} and
            defined $triggers{create};

    get "/${resource}/:id.:format" => $triggers{get};
    get "/${resource}/:id" => $triggers{get};

    put "/${resource}/:id.:format" => $triggers{update};
    put "/${resource}/:id" => $triggers{update};

    post "/${resource}.:format" => $triggers{create};
    post "/${resource}" => $triggers{create};

    del "/${resource}/:id.:format" => $triggers{delete};
    del "/${resource}/:id" => $triggers{delete};
};

register send_entity => sub {
    my ($entity, $http_code) = @_;

    $http_code ||= 200;

    status($http_code);
    $entity;
};

register status_ok => sub {
    send_entity($_[0]);
};

register status_created => sub {
    send_entity($_[0], 201);
};

register status_accepted => sub {
    send_entity($_[0], 202);
};

register status_bad_request => sub {
    send_entity({error => $_[0]}, 400);
};

register status_not_found => sub {
    send_entity({error => $_[0]}, 404);
};

register_plugin;

1;
__END__
=pod

=head1 NAME

Dancer::Plugin::REST - A plugin for writing RESTful apps with Dancer

=head1 SYNOPSYS

    package MyWebService;

    use Dancer;
    use Dancer::Plugin::REST;

    prepare_serializer_for_format;

    get '/user/:id.:format' => sub {
        User->find(params->{id});
    };

    # curl http://mywebservice/user/42.json
    { "id": 42, "name": "John Foo", email: "jhon.foo@example.com"}

    # curl http://mywebservice/user/42.yml
    --
    id: 42
    name: "John Foo"
    email: "jhon.foo@example.com"

=head1 DESCRIPTION

This plugin helps you write a RESTful webservice with Dancer.

=head1 KEYWORDS

=head2 prepare_serializer_for_format

When this pragam is used a before filter is set by the plugin to automatically
change the serializer when a format is detected in the URI.

That means that each route you define with a B<:format> token will trigger a
serializer defintion, if the format is known.

This lets you define all the REST action you like aas regular Dancer route
handlers, without taking care of the outgoing data format.

=head2 resource

This keyword lets you declare a resource your application will handle.

    resource user =>
        get    => sub { # return user where id = params->{id}   },
        create => sub { # create a new user with params->{user} },
        delete => sub { # delete user where id = params->{id}   },
        update => sub { # update user with params->{user}       };

    # this defines the following routes:
    # GET /user/:id
    # GET /user/:id.:format
    # POST /user/create
    # POST /user/create.:format
    # DELETE /user/:id
    # DELETE /user/:id.:format
    # PUT /user/:id
    # PUT /user/:id.:format

=head2 helpers

Some helpers are available. This helper will set an appropriate HTTP status for you.

=head3 status_ok

    status_ok({users => {...}});

Set the HTTP status to 200

=head3 status_created

    status_created({users => {...}});

Set the HTTP status to 201

=head3 status_accepted

    status_accepted({users => {...}});

Set the HTTP status to 202

=head3 status_bad_request

    status_bad_request("user foo can't be found");

Set the HTTP status to 400. This function as for argument a scalar that will be used under the key B<error>.

=head3 status_not_found

    status_not_found("users doesn't exists");

Set the HTTP status to 404. This function as for argument a scalar that will be used under the key B<error>.

=head1 LICENCE

This module is released under the same terms as Perl itself.

=head1 AUTHORS

This module has been written by Alexis Sukrieh C<< <sukria@sukria.net> >> and Franck
Cuny.

=head1 SEE ALSO

L<Dancer> L<http://en.wikipedia.org/wiki/Representational_State_Transfer>

=cut
