package Yancy::Backend::Role::Relational;
our $VERSION = '1.023';
# ABSTRACT: A role to give a relational backend relational capabilities

=head1 SYNOPSIS

    package Yancy::Backend::RDBMS;
    with 'Yancy::Backend::Role::Relational';

=head1 DESCRIPTION

This role implements utility methods to make backend classes work with
entity relations, using L<DBI> methods such as
C<DBI/foreign_key_info>.

=head1 REQUIRED METHODS

The composing class must implement the following methods either as
L<constant>s or attributes:

=head2 mojodb

The value must be a relative of L<Mojo::Pg> et al.

=head2 mojodb_class

String naming the C<Mojo::*> class.

=head2 mojodb_prefix

String with the value at the start of a L<DBI> C<dsn>.

=head1 METHODS

=head2 new

Self-explanatory, implements L<Yancy::Backend/new>.

=head2 id_field

Given a collection, returns the string name of its ID field.

=head1 SEE ALSO

L<Yancy::Backend>

=cut

use Mojo::Base '-role';
use Scalar::Util qw( blessed );

requires qw( mojodb mojodb_class mojodb_prefix );

sub new {
    my ( $class, $backend, $collections ) = @_;
    if ( !ref $backend ) {
        my $found = (my $connect = $backend) =~ s#^.*?:##;
        $backend = $class->mojodb_class->new( $found ? $class->mojodb_prefix.":$connect" : () );
    }
    elsif ( !blessed $backend ) {
        my $attr = $backend;
        $backend = $class->mojodb_class->new;
        for my $method ( keys %$attr ) {
            $backend->$method( $attr->{ $method } );
        }
    }
    my %vars = (
        mojodb => $backend,
        collections => $collections,
    );
    Mojo::Base::new( $class, %vars );
}

sub id_field {
    my ( $self, $coll ) = @_;
    return $self->collections->{ $coll }{ 'x-id-field' } || 'id';
}

1;