# Bing
Perl :camel: Module With Moose To Get Bing Search Results With Options.

# Requirements
- Moose
- LWP::UserAgent
use `cpan install Moose` , `cpan install LWP::UserAgent` if you don't have any of them.

# Usage Example

```perl
use Bing;
my $bing = Bing->new(keyword => "SearchWord" , pages => 10 , ua => "UserAgent String" , timeout=> 30 , count =>20);
$bing->search; #Starts The Search 
my @links = $bing->all;
my @domains = $bing->alld;
my @ips = $bing->alli;

print "Got Total : " $bing->lcount." Links \n";
print "Got Total : " $bing->dcount." Domains \n";
print "Got Total : " $bing->icount." Ips \n";
```
