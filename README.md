# Bing
Perl :camel: Module With Moose To Get Bing Search Results With Options.

# Requirements
- Moose
- LWP::UserAgent

use `cpan install Moose` , `cpan install LWP::UserAgent` if you don't have any of them.

# Usage Example

```perl
use lib "./"; #to use the module from the same dir of your code
use Bing;
my $bing = Bing->new(keyword => "SearchWord" , pages => 10 , ua => "UserAgent String" , timeout=> 30 , count =>20);
$bing->search; #Starts The Search 
my @links = $bing->all; #returns all uniq links from 10 pages 
my @domains = $bing->alld; #returns uniq domains of the the links
my @ips = $bing->alli; #returns uniq IPs of the domains

print "Got Total : " $bing->lcount." Links \n";
print "Got Total : " $bing->dcount." Domains \n";
print "Got Total : " $bing->icount." Ips \n";
```
