#!/usr/bin/perl

# open the csv file for reading
open(LOG, 'data.csv') or die "Unable to read the specified file.";
$line=0;
while(<LOG>)
{
	# skip processing the first line
	if ($line eq 0)	{
	}

	else {
		# store each 'column' as a seperate value in the array using ',' as the delimiter		
		@contactcase = split(',', $_);

		# store dates in variables
		$datesent=$contactcase[1];
		$datednc=$contactcase[2];

		# convert to epoch time (UNIX timestamp)
		$procsent=`date -d "$datesent" +"%s"`;
		$procdnc=`date -d "$datednc" +"%s"`;

		# check if 'date sent' is greater than 'date phone was added to dnc'
		if($procsent>$procdnc) {
			print "Found phone number - $contactcase[0]\n";
		}
	}
	# increase line counter
	$line++;
}
close LOG;
