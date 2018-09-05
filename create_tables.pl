#!perl

use lib "./" ;
use COMMON;

my $dbFile="./patents.sqlite";

print "This script create SQLite database and tables patent_details, image_details\n\n";

my $dbh=db_connect( $dbFile );
if( !$dbh ) {
  exit(1);
}

my $sql="
create table if not exists patent_details (
  patent_number text PRIMARY KEY , 
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
);
";

if ( ! db_exec( $dbh, $sql )) {
  db_disconnect($dbh);
  exit(1);  
}
$dbh->commit ;
print "Table patent_details was created\n";

my $sql="
create table if not exists image_details (
  patent_number text, 
  filename text,
  figure_caption text
);
";

if ( ! db_exec( $dbh, $sql )) {
  db_disconnect($dbh);
  exit(1);  
}
$dbh->commit ;
print "Table image_details was created\n";


db_disconnect($dbh);
print "Done\n";