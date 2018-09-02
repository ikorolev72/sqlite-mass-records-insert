# common functions and variables
use DBI;
use Data::Dumper;


my $dbFile="./patents.sqlite";





sub db_connect {

my $dbfile = shift; 
my $dsn      = "dbi:SQLite:dbname=$dbfile";
my $user     = "";
my $password = "";

my $dbh = DBI->connect($dsn, $user, $password, {
   PrintError       => 1,
   RaiseError       => 0,
   AutoCommit       => 0,
   FetchHashKeyName => 'NAME_lc',
}) or w2log ( "Cannot connect to database : $DBI::errstr" );
return $dbh;
}

sub db_disconnect {
	my $dbh=shift;
	$dbh->disconnect;
}


sub get_date {
	my $time=shift() || time();
	my $format=shift || "%s-%.2i-%.2i %.2i:%.2i:%.2i";
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($time);
	$year+=1900;$mon++;
    return sprintf( $format,$year,$mon,$mday,$hour,$min,$sec);
}	



sub db_exec {
	my $dbh=shift;
  my $sql=shift;
	my $sth; 
	my $rv;

  eval{
	  $sth = $dbh->prepare( $sql );
    $rv = $sth->execute( );
  };
	if ( $@ ) {
		w2log ( "Someting wrong : sql command : $sql . Error: $DBI::errstr ". $@  );
		return 0;
	}	
	return 1;
}

sub db_insert {
	my $dbh=shift;
  my $table=shift;	
  my $record=shift;
	my $sth; 
	my $rv;
  my @columns=();
  my @values=();
  foreach my $key ( keys(%{$record}) ) {
    push( @columns, $key );
    push( @values, $record->{ $key } );
  }	
	#my $sql="INSERT OR IGNORE into $table
	my $sql="INSERT into $table
					( ". join(',', @columns  ) ." )
					values 
					( ".join( ',', map{ '?' } @columns )." ) ;";	

#print Dumper( $sql, @values );
  eval{
	  $sth = $dbh->prepare( $sql );
    $rv = $sth->execute( @values );
  };
	if ( $@ ) {
		w2log ( "Someting wrong : sql command : $sql . Error: $DBI::errstr ". $@  );
		return 0;
	}	
	return 1;
}


sub w2log {
	my $msg=shift;
	my $noPrint=shift;
	#open (LOG,">>$Paths->{LOG}") || print ("Can't open file $Paths->{LOG}. $msg") ;
	#print LOG get_date()."\t$msg\n";
	#print STDERR $msg;
	#close (LOG);
  if( ! $noPrint ) {
	  print STDOUT get_date()."\t$msg\n";
  }
}


1;