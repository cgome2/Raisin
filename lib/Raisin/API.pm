package Raisin::API;

use strict;
use warnings;
use feature ':5.12';

use base 'Exporter';

use Raisin;

our @EXPORT = qw(
    run new

    mount middleware

    plugin api_format api_version

    before before_validation
    after_validation after

    namespace route_param
    req res params session
    delete get head options patch post put
);

my $app;
#my %SETTINGS = (_NS => ['']);
my %SETTINGS = ();
my @NS = ('');

sub import {
    my $class = shift;
    $class->export_to_level(1, @_);

    strict->import;
    warnings->import;
    feature->import(':5.12');

    my $caller = caller;
    $app ||= Raisin->new(caller => $caller);
}

#
# Execution
#
sub run { $app->run }
sub new { $app->run }

#
# Compile
#
sub mount { $app->mount_package(@_) }
sub middleware { $app->add_middleware(@_) }

#
# Hooks
#
sub before { $app->add_hook('before', shift) }
sub before_validation { $app->add_hook('before_validation', shift) }

sub after_validation { $app->add_hook('after_validation', shift) }
sub after { $app->add_hook('after', shift) }

#
# Namespace DSL
#
sub namespace {
    my ($name, $block, %args) = @_;

    if ($name) {
        my %prev_settings = %SETTINGS;

        push @NS, $name;
        @SETTINGS{ keys %args } = values %args;

        # Going deeper
        $block->();

        pop @NS;
        %SETTINGS = ();
        %SETTINGS = %prev_settings;
    }

    (join '/', @NS) || '/';
}

sub route_param {
    my ($param, $type, $block) = @_;
    namespace(":$param", $block, named => [required => [$param, $type]]);
}

#
# Actions
#
sub delete  { $app->add_route('DELETE',  namespace(), %SETTINGS, @_) }
sub get     { $app->add_route('GET',     namespace(), %SETTINGS, @_) }
sub head    { $app->add_route('HEAD',    namespace(), %SETTINGS, @_) }
sub options { $app->add_route('OPTIONS', namespace(), %SETTINGS, @_) }
sub patch   { $app->add_route('PATCH',   namespace(), %SETTINGS, @_) }
sub post    { $app->add_route('POST',    namespace(), %SETTINGS, @_) }
sub put     { $app->add_route('PUT',     namespace(), %SETTINGS, @_) }

#
# Request and Response shortcuts
#
sub req { $app->req }
sub res { $app->res }
sub params { $app->params(@_) }
sub session { $app->session(@_) }

#
#
#
sub plugin { $app->load_plugin(@_) }
sub api_format { $app->api_format(@_) }
sub api_version { $app->api_version(@_) }

#sub error {
#    # NOTE render error 500?
#    $app->res->render_error(@_);
#}

__END__

=head1 NAME

Raisin::API - Provides Raisin DSL

=head1 DESCRIPTION

See L<Raisin>.

=cut

1;