#!perl

use lib "./" ;
use COMMON;
use Getopt::Long;


my $dbFile="./patents.sqlite";
my $filename='';
my $table='patent_details';
my $commitAfterRecords=10000; # commit when inserted so records 
my $help=0;
my $version="1.1 2018.09.03";


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

open( IN, $filename ) || die "Cannot open file $filename";

my $recordsCount=0;
while(<IN>){
  chomp();
  my $record=parse_data_patent_details( $_ );
  if( !$record ) {
    w2log( "Cannot insert data into table $table, incorrect data: $_") ;
    next;
  }  
  if ( db_insert( $dbh, $table, $record )) {
    $recordsCount++;
  }
  if( ($recordsCount % $commitAfterRecords) == 0 ) {
    $dbh->commit ;
    print "Inserted $recordsCount records\n";
  }  
}
close(IN);
$dbh->commit ;

db_disconnect($dbh);
print "Inserted $recordsCount records\n";
print "Done\n";




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
	exit (1);
}

