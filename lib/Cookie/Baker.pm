package Cookie::Baker;

use 5.008005;
use strict;
use warnings;
use base qw/Exporter/;
use URI::Escape;

BEGIN {
    our $VERSION = "0.03";
    our @EXPORT = qw/bake_cookie crush_cookie/;
    my $use_pp = $ENV{COOKIE_BAKER_PP};
    if (!$use_pp) {
        eval {
            require Cookie::Baker::XS;
        };
        $use_pp = !!$@;
    }
    if ($use_pp) {
        *crush_cookie = \&pp_crush_cookie;
    }
    else {
        *crush_cookie = \&Cookie::Baker::XS::crush_cookie;
    }
}

sub bake_cookie {
    my ($name,$val) = @_;

    return '' unless defined $val;
    my %args = ref $val ? %{$val} : (value => $val);
    $name = URI::Escape::uri_escape($name) if $name =~ m![^a-zA-Z\-\._~]!;
    my $cookie = "$name=" . URI::Escape::uri_escape($args{value}) . '; ';
    $cookie .= 'domain=' . $args{domain} . '; '  if $args{domain};
    $cookie .= 'path='. $args{path} . '; '       if $args{path};
    $cookie .= 'expires=' . _date($args{expires}) . '; ' if $args{expires};
    $cookie .= 'max-age=' . $args{"max-age"} . '; ' if $args{"max-age"};
    $cookie .= 'secure; '                     if $args{secure};
    $cookie .= 'HttpOnly; '                   if $args{httponly};
    substr($cookie,-2,2,'');
    $cookie;
}

my @MON  = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @WDAY = qw( Sun Mon Tue Wed Thu Fri Sat );

my %term = (
    's' => 1,
    'm' => 60,
    'h' => 3600,
    'd' => 86400,
    'M' => 86400 * 30,
    'y' => 86400 * 365,
);

sub _date {
    my $expires = shift;

    my $expires_at;
    if ($expires =~ /^\d+$/) {
        # all numbers -> epoch date
        $expires_at = $expires;
    }
    elsif ( $expires =~ /^([-+]?(?:\d+|\d*\.\d*))([smhdMy]?)/ ) {
        no warnings;
        my $offset = ($term{$2} || 1) * $1;
        $expires_at = time + $offset;
    }
    elsif ( $expires  eq 'now' ) {
        $expires_at = time;
    }
    else {
        return $expires;
    }
    my($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime($expires_at);
    $year += 1900;
    # (cookies use '-' as date separator, HTTP uses ' ')    
    return sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
                   $WDAY[$wday], $mday, $MON[$mon], $year, $hour, $min, $sec);
}

sub pp_crush_cookie {
    my $cookie_string = shift;
    return {} unless $cookie_string;
    my %results;
    my @pairs = grep m/=/, split "[;,] ?", $cookie_string;
    for my $pair ( @pairs ) {
        # trim leading trailing whitespace
        $pair =~ s/^\s+//; $pair =~ s/\s+$//;

        my ($key, $value) = map URI::Escape::uri_unescape($_), split( "=", $pair, 2 );

        # Take the first one like CGI.pm or rack do
        $results{$key} = $value unless exists $results{$key};
    }
    return \%results;
}

1;
__END__

=encoding utf-8

=head1 NAME

Cookie::Baker - Cookie string generator / parser

=head1 SYNOPSIS

    use Cookie::Baker;

    $headers->push_header('Set-Cookie', bake_cookie($key,$val));

    my $cookies_hashref = crush_cookie($headers->header('Cookie'));

=head1 DESCRIPTION

Cookie::Baker provides simple cookie string generator and parser.

=head1 XS IMPLEMENTATION

This module try to use L<Cookie::Baker::XS>'s crush_cookie by default
and fail to it, use Cookie::Baker's pure-perl crush_cookie.

There is no XS implementation of bake_cookie yet.

=head1 FUNCTION

=over 4

=item bake_cookie

  my $cookie = bake_cookie('foo','val');
  my $cookie = bake_cookie('foo', {
      value => 'val',
      path => "test",
      domain => '.example.com',
      expires => '+24h'
  } );

Generates cookie string for HTTP response header.
First argument is cookies' name and seconds argument is plain string or hash reference that
can contain keys such as C<value>, C<domain>, C<expires>, C<path>, C<httponly>, C<secure>,
C<max-age>.


=over 4

=item value

Cookie's value

=item domain

Cookie's domain.

=item expires

Cookie's expires date time. several formats are supported

  expires => time + 24 * 60 * 60 # epoch time
  expires => 'Wed, 03-Nov-2010 20:54:16 GMT' 
  expires => '+30s' # 30 seconds from now
  expires => '+10m' # ten minutes from now
  expires => '+1h'  # one hour from now 
  expires => '-1d'  # yesterday (i.e. "ASAP!")
  expires => '+3M'  # in three months
  expires => '+10y' # in ten years time
  expires => 'now'  #immediately

=item path

Cookie's path.

=item httponly

If true, give HttpOnly flag. false by default.

=item secure

If true, give secure flag. false by default.

=back

=item crush_cookie

Parses cookie string and returns hashref. 

    my $cookies_hashref = crush_cookie($headers->header('Cookie'));
    my $cookie_value = $cookies_hashref->{cookie_name}  

=back

=head1 SEE ALSO

CPAN already has many cookie related modules. But there is not simple cookie string generator and parser modules.

L<CGI>, L<CGI::Simple>, L<Plack>, L<Dancer::Cookie>

=head1 LICENSE

Copyright (C) Masahiro Nagano.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo@gmail.comE<gt>

=cut

