#!/bin/perl

use v5.10;

use File::Fetch;
use File::Basename;
use English;
use Data::Dumper;
use Mojo::DOM;
use strict;


my @fields = (
                 'Surname'
                ,'Title'
                ,'Forename'
                ,'Speciality'
                ,'Street'
                ,'City'
                ,'Province'
                ,'Postcode'
                ,'Phone'
);

my @links = map { chop $_; $_ } `find Cache1/ -type f -name \\*html `;
#my @links = `find Cache0/ -type f -name \\*html `;

#say Dumper \@links;
my @data;
foreach my $l ( @links ) {
    #say $l;
    push @data, fetch_level2( $l );
    #exit 0;
}


open CSV, ">can53.csv";
say CSV join '|', @fields;
foreach my $d (@data) {

    say CSV join '|', map {
        $d->{$_} || ''
    } @fields;

}
close CSV;


my $o=`python /home/selenium/ch19/csv2excel.py --sep '|' --title --output ./can53.xls ./can53.csv`;

say "Py output: $o" if $o;

exit 0;

### Subs
my $count=1;
sub fetch_level2 {

    my $link = shift;
    $count=1 unless $count;
    #printf "$link: ";

    my $content = `cat $link`;

    #say length $content;

    my $dom = Mojo::DOM->new($content);

    my $div01 = $dom->find('div.directory01');
    my $div02 = $dom->find('div.directory02');

    #say 'N Div1:', scalar @$div01, ' N Div2:', scalar @$div02;

    my @data01 = find_div( $div01, $link );
    my @data02 = find_div( $div02, $link );

    return (@data01, @data02);

}



## here
sub find_div {
    my $dom = shift;
    my $link = shift;

    my @data;
    for( my $i=0;  $i<scalar @$dom; $i++ ) {

        my $span = $dom->[$i]->at('span');
        $span .= '';
        $span =~ s/&#39;/'/g;
        # <span class="stdText12"><strong>Alibhai, Dr. Amin</strong> (Oral Surgey)<br>386 Stavanger Drive<br>St. John&#39;s, NL��A1A 5M9<br>709-754-0579<br></span>
        if( $span =~ m/<span class="\S+">(.*)<\/span>/ ) {

            my $head;
            my $street;
            my $address0;
            my $phone;

            #say "Span: $1";
            my @parts = split /<br>/, $1;
            #say "Scalar: ", scalar @parts;

            $head = shift @parts;

            my $n = scalar @parts;
            #die "less then zero" if $n-2 <0;
            if( $n ==  2 ) {

                $street = $parts[0];
                $address0 = $parts[1];

            } elsif( $n == 3 ) {
                $street = $parts[0];
                $address0 = $parts[1];
                $phone = $parts[2];

            } elsif( $n == 4 ) {
                $street = $parts[1] . ' ' . $parts[0];
                $address0 = $parts[2];
                $phone = $parts[3];

                #foreach my $p ( @parts ) {
                #    say "\t:$p:";
                #}
            }

            my $province;
            my $postcode;
            #say "address0: $address0";
            my($city,$rest) = split /, /, $address0;

            if( $rest =~ m/^(\S+)\xa0\xa0(.*)$/ ) {
                $province = $1;
                $postcode = $2; 
                #say $rest;

            } else {
                #print "link: $link SPAN:",$n; #, '  ', "\n";
                #say "\tcity: $city";
                #say "\trest: $rest";
            }

            #exit 0;

            #next;

            $head =~ s/<strong>//;
            #say $head;
            my ($head0,$speciality) = split /<\/strong>\s*/, $head;
            $speciality =~ s/\(|\)//g;
            #say "\t$head0";
            my ($surname,$title,$forename) = split /,?\s+/, $head0;

            if(0) {            
            say "\tsurname: $surname";
            say "\ttitle: $title";
            say "\tforename: $forename";
            say "\tspeciality: $speciality";
            say "\tstreet: $street";
            say "\tcity: $city";
            say "\tprovince: $province";
            say "\tpostcode: $postcode";
            say "\tphone: $phone";
            }

            push @data, {
                Surname=>$surname
                ,Title=>$title
                ,Forename=>$forename
                ,Speciality=>$speciality
                ,Street=>$street
                ,City=>$city
                ,Province=>$province
                ,Postcode=>$postcode
                ,Phone=>$phone
            };

        } else {

            say $span;
            die "Error  format";

        } 

        #last;
    }
    return @data;
}

__END__
