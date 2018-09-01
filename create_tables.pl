#!perl

use lib "./" ;
use DBI;
use COMMON;


my $dbFile="./patents.sqlite";

my $sql="
create table if not exists patent_details (
  patent_number text  PRIMARY KEY, 
  country text,
  ip_type text,
  year  integer,
  part_labels text,
  ipc_classes text,
  cpc_classes text,
  priority_date date,
  filing_date date,
  publication_date date,
  grant_date date,
  applicant text,
  Inventor text,
  drawing_sheets integer,
  figures integer
)
";


my $dbh=db_connect( $dbFile );
if( !$dbh ) {
  exit(1);
}

if ( ! db_exec( $dbh, $sql )) {
  db_disconnect($dbh);
  exit(1);  
}

$dbh->commit ;
db_disconnect($dbh);
print "Done\n";