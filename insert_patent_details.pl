#!perl

use lib "./" ;
use COMMON;
use Getopt::Long;


my $dbFile="./patents.sqlite";
my $filename='';
my $commitAfterRecords=1000; # commit when inserted so records 

GetOptions (
        'filename=s' => \$filename,
        'database=s' => \$dbFile,
        "help|h|?"  => \$help ) ;


if( ! -f $filename ) {
  show_help( "File with data '$filename' do not exist");
}
if( ! -f $dbFile ) {
  show_help( "Database file '$dbFile' do not exist");
}

show_help( ) if( $help )	;


my $dbh=db_connect( $dbFile );
if( !$dbh ) {
  exit(1);
}

if ( ! db_exec( $dbh, $sql )) {
  db_disconnect($dbh);
  exit(1);  
}

open( IN, $filename ) || die "Cannot open file $filename";

my $recordsCount=0;
while(<IN>){
  chomp();
  my $record=parse_data_patent_details( $_ );
  if ( db_insert( $dbh, 'patent_details', $record )) {
    $recordsCount++;
    print "$recordsCount\n";
  }
  if( ($recordsCount % $commitAfterRecords) == 0 ) {
    $dbh->commit ;
  }  
}
close(IN);
$dbh->commit ;

db_disconnect($dbh);
print "Inserted $recordsCount records\nDone\n";



sub parse_data_patent_details {
  my $str=shift;
  my $record;
  #US	US9854720	patent-grant	2017
  my @data=split( /\s+/, $str) ;
  $record->{'country'}=$data[0];
  $record->{'patent_number'}=$data[1];
  $record->{'ip_type'}=$data[2];
  $record->{'year'}=$data[3];
  return( $record );
}


sub show_help {
		my $msg=shift;
        print STDERR ("##	$msg\n\n") if( $msg);
        print STDERR ("Version $version
This script insert data from file into tables patent_details
Usage: $0 --filename=DATA_FILE [--database DB_FILE] [--help]
Where:
	--filename=DATA_FILE - read data from this file and insert into db
	--database DB_FILE - SQLite db ( default './patents.sqlite' )
	--help - this help
Sample:	${0} --filename=Patent_details_table.txt
");
	print "Press ENTER to exit:";
	<STDIN>;
	exit (1);
}

