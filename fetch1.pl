#!/bin/perl

use v5.10;

use File::Fetch;
use File::Basename;
use English;
use Data::Dumper;
use strict;


my $cache_dir = './Cache1';
#say `bash ../rotate/rotate.sh $cache_dir 2>&1`;
mkdir $cache_dir;

#my @links = map { chop $_; $_ } `find Links/hrefs -type f -exec grep ^http '{}' \\;  `;
my @options = map { chop $_; $_; } `cat select.txt | head -1000`;

#say Dumper \@links;

foreach my $o ( @options ) {
   #say ">$o<";
   fetch( $o );
#exit 0;
}

exit 0;

### Subs

my $i=1;
sub fetch {

    my $o = shift;
    my $ouu = $o;
    $ouu =~ s/\s/%20/g; $ouu =~ s/'/%27/g; 

    $o =~ s/\s/_/g;
    $o =~ s/'/_/g;

    $i=1 unless $i ;

    my $link = 'http://nldb.ca/directory/directory.aspx?FL='.$ouu;
    my $file0 = $cache_dir.'/'.$o.'.html';
    say $link, ':', $file0;
#return;

    my $s = -s $file0;
    if( $s ) {
        say "Already [$s]";
        return;
    }

    my $ff = File::Fetch->new( uri => $link );
    my $where = $ff->fetch( to => '/tmp' );
    #say $ff->file;
    #say `ls -lt $where`;

    #my $file = $cache_dir.'/'.$ff->file.'.html';
    my $output = `mv $where $file0 2>&1`;
    say "Done [$i] $output";
    $i++;
}

