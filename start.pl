#!/usr/bin/perl
use strict;
use warnings;
use XML::Simple;
use DBI;
use Data::Dumper;
use Error;
use File::Basename;
use NAABSCAN::XML;

require 'config.pl';
our $dbHost;
our $dbUser ;
our $dbBase ;
our $dbPwd ;
our $xmlFolder;
our $doneFolder;

my $dbh = DBI->connect('DBI:mysql:'.$dbBase, $dbUser, $dbPwd
                   ) || die "Could not connect to database: $DBI::errstr";

my $xmlImport = NAABSCAN::XML->new( $dbh, $xmlFolder,$doneFolder);
$xmlImport->scan();

$dbh->disconnect();
