# NAME

Cookie::Baker - Cookie string generator / parser

# SYNOPSIS

    use Cookie::Baker;

    $headers->push_header('Set-Cookie', bake_cookie($key,$val));

    my $cookies_hashref = crush_cookie($headers->header('Cookie'));

# DESCRIPTION

Cookie::Baker provides simple cookie string generator and parser.

# XS IMPLEMENTATION

This module try to use [Cookie::Baker::XS](http://search.cpan.org/perldoc?Cookie::Baker::XS)'s crush\_cookie by default
and fail to it, use Cookie::Baker's pure-perl crush\_cookie.

There is no XS implementation of bake\_cookie yet.

# FUNCTION

- bake\_cookie

        my $cookie = bake_cookie('foo','val');
        my $cookie = bake_cookie('foo', {
            value => 'val',
            path => "test",
            domain => '.example.com',
            expires => '+24h'
        } );

    Generates cookie string for HTTP response header.
    First argument is cookies' name and seconds argument is plain string or hash reference that
    can contain keys such as `value`, `domain`, `expires`, `path`, `httponly`, `secure`,
    `max-age`.



    - value

        Cookie's value

    - domain

        Cookie's domain.

    - expires

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

    - path

        Cookie's path.

    - httponly

        If true, give HttpOnly flag. false by default.

    - secure

        If true, give secure flag. false by default.

- crush\_cookie

    Parses cookie string and returns hashref. 

        my $cookies_hashref = crush_cookie($headers->header('Cookie'));
        my $cookie_value = $cookies_hashref->{cookie_name}  

# SEE ALSO

CPAN already has many cookie related modules. But there is not simple cookie string generator and parser modules.

[CGI](http://search.cpan.org/perldoc?CGI), [CGI::Simple](http://search.cpan.org/perldoc?CGI::Simple), [Plack](http://search.cpan.org/perldoc?Plack), [Dancer::Cookie](http://search.cpan.org/perldoc?Dancer::Cookie)

# LICENSE

Copyright (C) Masahiro Nagano.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Masahiro Nagano <kazeburo@gmail.com>
