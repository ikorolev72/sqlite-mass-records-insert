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
	  print STDERR get_date()."\t$msg\n";
  }
}


sub parse_data_patent_details {
  my $str=shift;
  my $record;
  my ( $country, $patent_number, $ip_type, $year )=split( /\s+/, $str, 4 ) ;
  $record->{'country'}=$country;
  $record->{'patent_number'}=$patent_number;
  $record->{'ip_type'}=$ip_type;
  $record->{'year'}=$year;
	# if do not defined any element
	if( !$country || !$patent_number || !$ip_type || !$year ) {
		return(0);
	}	
  return( $record );
}



sub parse_data_image_details {
  my $str=shift;
  my $record;
  my ( $filename, $patent_number, $figure_caption)=split( /\s+/, $str, 3 ) ;
  $record->{'patent_number'}=$patent_number;
  $record->{'filename'}=$filename;
  $record->{'figure_caption'}=$figure_caption;

	# if do not defined any element
	if( !$filename || !$patent_number  ) {
		return(0);
	}
  return( $record );
}


1;