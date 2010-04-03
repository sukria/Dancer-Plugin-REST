package Dancer::Plugin::REST;
use Dancer ':syntax';
use Dancer::Plugin;

register prepare_serializer_for_format =>
sub {
    my $serializers = {
        'json' => 'JSON',
        'yml'  => 'YAML',
        'xml'  => 'XML',
        'dump' => 'Dumper',
    };

    before sub {
        my $format = params->{'format'};
        set serializer $serializers->{$format}
            if $format && $serializers->{$format};
    };
};

register_plugin;

