package Bing {
    use Moose;
    use LWP::UserAgent;
    use experimental 'smartmatch';
    has 'keyword' => ( is => 'rw', isa => 'Str', required => 1 );
    has 'pages'   => ( is => 'rw', isa => 'Int', default  => 10 );
    has 'count'   => ( is => 'rw', isa => 'Int', default  => 20 );
    has 'timeout' => ( is => 'ro', isa => 'Int', default  => 30 );
    has 'ua'      => (
        is      => 'rw',
        isa     => 'Str',
        default => "Mozilla/4.8 [en] (Windows NT 6.0; U)"
    );
    has 'tag' => ( is => 'rw', isa => 'Str', default => "h2" );
    has 'links' => (
        default => sub { [] },
        traits  => ['Array'],
        is      => 'rw',
        isa     => 'ArrayRef[Str]',
        handles => {
            all       => 'elements',
            add_links => 'push',
            lcount    => 'count',
            clinks    => 'clear'
        }
    );
    has 'ips' => (
        default => sub { [] },
        traits  => ['Array'],
        is      => 'rw',
        isa     => 'ArrayRef[Str]',
        handles => {
            alli    => 'elements',
            add_ips => 'push',
            icount  => 'count',
            cips    => 'clear'
        }
    );
    has 'domains' => (
        default => sub { [] },
        traits  => ['Array'],
        is      => 'rw',
        isa     => 'ArrayRef[Str]',
        handles => {
            alld        => 'elements',
            add_domains => 'push',
            dcount      => 'count',
            cdomains    => 'clear'
        }
    );

    sub search {
        print "Working\n";
        my $self = shift;
        print $self->keyword . "\n";
        print $self->timeout . "\n";
        print $self->pages . "\n";
        my $page = 0;
        for ( my $i = 0 ; $i < $self->pages * 10 ; $i += 10 ) {

            my $ua = LWP::UserAgent->new(
                agent   => $self->ua,
                timeout => $self->timeout
            );
            my $html =
              $ua->get( 'http://www.bing.com/search?q='
                  . $self->keyword
                  . '&count='
                  . $self->count
                  . '&first='
                  . $i
                  . '&FORM=PERE' )->content;
            my $check  = index( $html, 'sb_pagN' );
            my $check1 = index( $html, 'class="sb_count"' );
            if ( $check == -1 or $check1 == -1 ) {
                last;
            }
            my @links   = $self->get_links( $html, $self->tag );
            my @domains = $self->get_domains(@links);
            my @ips     = $self->get_ips(@domains);
            $self->add_links(@links);
            $self->add_domains(@domains);
            $self->add_ips(@ips);
            $page++;
            print "Done Searching Page : $page ..\n";
        }
        $self->clean;
    }

    sub get_ips {
        my $self    = shift;
        my @domains = @_;
        my @ips ; 
        for my $domain (@domains) {
            my $ip = ( gethostbyname($domain) )[4];
            if ($ip ){
                my ( $a, $b, $c, $d ) = unpack( 'C4', $ip );
                my $ips = "$a.$b.$c.$d";
                if ($ips ne "..."){
                    push @ips, $ips; 
                }
                
            }
            
        }
        return @ips;
    }

    sub get_domains {
        my $self    = shift;
        my @links   = @_;
        my @domains;
        for my $link (@links) {
            unless ( ( $link =~ /\/$/ )
                or ( $link =~ /([^\/]\/[^\/]+\.[^\/]+)/ ) )
            {
                $link = $link . "/";
            }
            if ( $link =~ m|(\w+)://([^/:]+)(:\d+)?/(.*)| ) {
                my $domain = $2;
                push @domains, $domain; 
            }
        }
        return @domains;
    }

    sub get_links {
        my $self  = shift;
        my $html  = shift;
        my $tag   = shift;
        my @links = $self->all;
        my @links1;
        while ( $html =~
m/<$tag>(<\s*?a\s+?href\s*?=(\"|\')([^(\"|\')]*?)(\"|\')([^>]*?)>(.*?)<\s*?\/a\s*?>)/gis
          )
        {
            my $link;
            if ( $tag eq "(.*?)" ) {
                $link = $4;
            }
            else {
                $link = $3;
            }

            unless ( $link =~ /^http:\/\// or $link =~ /^https:\/\// ) {
                $link = "http://" . $link;
            }
            unless ( ( $link =~ /\/$/ )
                or ( $link =~ /([^\/]\/[^\/]+\.[^\/]+)/ ) )
            {
                $link = $link . "/";
            }
            
                push @links1, $link;

            
        }
        return @links1;
    }
    sub clean {
        my $self = shift;
        my @domains = uniq($self->alld);
        my @links = uniq($self->all);
        my @ips = uniq($self->alli);
        $self->clinks;
        $self->cdomains;
        $self->cips;
        $self->add_links(@links);
        $self->add_domains(@domains);
        $self->add_ips(@ips);
    }
    sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
    }

}
1;
