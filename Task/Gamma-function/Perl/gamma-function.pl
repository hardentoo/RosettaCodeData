use strict;
use warnings;
use constant pi => 4*atan2(1, 1);
use constant e  => exp(1);

# Normally would be:  use Math::MPFR
# but this will use it if it's installed and ignore otherwise
my $have_MPFR = eval { require Math::MPFR; Math::MPFR->import(); 1; };

sub Gamma {
    my $z = shift;
    my $method = shift // 'lanczos';
    if ($method eq 'lanczos') {
        use constant g => 9;
        $z <  .5 ?  pi / sin(pi * $z) / Gamma(1 - $z, $method) :
        sqrt(2* pi) *
        ($z + g - .5)**($z - .5) *
        exp(-($z + g - .5)) *
        do {
            my @coeff = qw{
            1.000000000000000174663
        5716.400188274341379136
      -14815.30426768413909044
       14291.49277657478554025
       -6348.160217641458813289
        1301.608286058321874105
        -108.1767053514369634679
           2.605696505611755827729
          -0.7423452510201416151527e-2
           0.5384136432509564062961e-7
          -0.4023533141268236372067e-8
            };
            my ($sum, $i) = (shift(@coeff), 0);
            $sum += $_ / ($z + $i++) for @coeff;
            $sum;
        }
    } elsif ($method eq 'taylor') {
        $z <  .5 ? Gamma($z+1, $method)/$z     :
        $z > 1.5 ? ($z-1)*Gamma($z-1, $method) :
	do {
	    my $s = 0; ($s *= $z-1) += $_ for qw{
	    0.00000000000000000002 -0.00000000000000000023 0.00000000000000000141
	    0.00000000000000000119 -0.00000000000000011813 0.00000000000000122678
	    -0.00000000000000534812 -0.00000000000002058326 0.00000000000051003703
	    -0.00000000000369680562 0.00000000000778226344 0.00000000010434267117
	    -0.00000000118127457049 0.00000000500200764447 0.00000000611609510448
	    -0.00000020563384169776 0.00000113302723198170 -0.00000125049348214267
	    -0.00002013485478078824 0.00012805028238811619 -0.00021524167411495097
	    -0.00116516759185906511 0.00721894324666309954 -0.00962197152787697356
	    -0.04219773455554433675 0.16653861138229148950 -0.04200263503409523553
	    -0.65587807152025388108 0.57721566490153286061 1.00000000000000000000
	    }; 1/$s;
	}
    } elsif ($method eq 'stirling') {
        no warnings qw(recursion);
        $z < 100 ? Gamma($z + 1, $method)/$z :
        sqrt(2*pi*$z)*($z/e + 1/(12*e*$z))**$z / $z;
    } elsif ($method eq 'MPFR') {
        my $result = Math::MPFR->new();
        Math::MPFR::Rmpfr_gamma($result, Math::MPFR->new($z), 0);
        $result;
    } else { die "unknown method '$method'" }
}

for my $method (qw(MPFR lanczos taylor stirling)) {
    next if $method eq 'MPFR' && !$have_MPFR;
    printf "%10s: ", $method;
    print join(' ', map { sprintf "%.12f", Gamma($_/3, $method) } 1 .. 10);
    print "\n";
}
