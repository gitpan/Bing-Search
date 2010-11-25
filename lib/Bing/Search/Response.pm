package Bing::Search::Response;
use Carp;
use Moose;
use Moose::Util::TypeConstraints;
use JSON;

subtype 'Bing::Search::Response::Types::JSON'
      => as 'HashRef';

coerce 'Bing::Search::Response::Types::JSON'
   => from 'Str'
   => via { decode_json( $_ ) };

has 'data' => ( 
   is => 'rw',
   coerce => 1,
   isa => 'Bing::Search::Response::Types::JSON',
   trigger => \&_parse
);

with 'Bing::Search::Role::Response::Version';
with 'Bing::Search::Role::Response::Query';
with 'Bing::Search::Role::Response::AlterationOverride';

has 'results' => ( 
   is => 'rw',
   isa => 'ArrayRef[Bing::Search::Result]',
   default => sub { [] }
);

sub _parse { 
   my $self = shift;
   my $data = $self->data;
   my @sets;
   for my $set ( keys %{$data->{SearchResponse}} ) {
      next if $set eq 'Query';
      next if $set eq 'Version';
      next if $set eq 'AlternationOverride';
      my $class = 'Bing::Search::Result::' . $set;
      eval "require $class" or croak $@;
      my $result_list;
      if( $set eq 'Errors' ) { 
         $result_list = delete $data->{SearchResponse}->{$set};
      } else { 
         $result_list = delete $data->{SearchResponse}->{$set}->{Results};
      }
      for my $res ( @$result_list ) { 
         my $ob = $class->new( data => $res );
         $ob->_populate;
         push @sets, $ob;
      }
   }
   $self->results( \@sets );
}  

__PACKAGE__->meta->make_immutable;


=head1 NAME

Bing::Search::Response - A response object for teh Bing AJAX Api

=head1 SYNOPSIS

    my $resulsts = $search->search();

    my $array_ref = $response->results;

=head1 DESCRIPTION

This object contains the results from a search.  Or something telling
you why things went horribly wrong.  It should be noted that this 
does B<not> tell you if your request failed at some LWP-style failure
-- for that, check the C<request_obj> of your L<Bing::Search> object.

=head1 METHODS

Responses are generally a read-only ordeal.  You may change the values
here in these various methods, if it makes you feel better.  Nothing
will try to stop you.  Won't do much, though.

=over 3

=item C<Version>

Contains the Bing API version. 

=item C<Query>

The query sent to Bing.  Use this for verification.

=item C<AlterationOverride>

If the query sent to Bing is "fixed" automatically by Bing, this string
will allow you to re-submit the query "as-is".  The example from the Bing
documentation:

=over 3

For example, if the original query is microsift offic, then 
AlterationOverrideQuery would be +microsift +offic

=back

=item C<results>

This is the biggie.  This is an arrayref of the L<Bing::Search::Result> objects.
This is what you want to fiddle with.  


=item C<data>

A hashref, it initially contains the deparsed JSON structure.  As objects are
populated, it is depopulated.  Anything left over is something Bing sent but
was, for some reason, not handled.  In a perfect world, by the time you're able
to do anything, this should be empty.  You probably don't want to fiddle with it.

=item C<_parse>

Don't mess with this.  It's what turns C<data> into objects.  Seriously.  Just
leave it alone.

=back

=head1 BUGS

Probably.  Patches welcome.

=head1 SEE ALSO

L<Bing::Search>

=head1 AUTHOR

Dave Houston, L< dhouston@cpan.org >, 2010

=head1 LICENSE

This library is free software; you may redistribute and/or modify it under the 
same terms as Perl itself.


