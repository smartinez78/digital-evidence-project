#!/usr/bin/perl
# Script Name: classdef.pl
# This script will find all entries in the messagelist2.csv file that meet the class definition and combine the message information with the corresponding contact information in the contactlist.csv file. These entries will then be appended to a final document.

# STEP 1 - compare <date message sent> and <date added to dnc list>
print "Beginning Step 1...\n";

# open the csv file for reading
open(LOG, 'data.csv') or die "Unable to read the data.csv.";

$line=0; # informal line counter

while(<LOG>)
{
	# skip processing the first line
	if ($line eq 0)	{
	}

	else {
		# store each 'column' as a seperate value in the array using ',' as the delimiter
		@messagecase = split(',', $_);

		# store the two dates in separate variables
		$datesent=$messagecase[1];
		$datednc=$messagecase[2];

		# convert to epoch time (UNIX timestamp)
		$eqsent=`date -d "$datesent" +"%s"`;
		$eqdnc=`date -d "$datednc" +"%s"`;

		# check if 'date sent' is greater than 'date phone was added to dnc'
		if($eqsent>$eqdnc) {
			open(RECORD, ">>file1.csv"); # write values to file1.csv
			print RECORD "$messagecase[0],$messagecase[1],$messagecase[2],$messagecase[3],$messagecase[4]";
			close RECORD;
		}
	}

	$line++; # increase the line counter
}
close LOG;

# STEP 2 - call bash script and use awk to pull 'Sent' and 'Delivered' entries
print "Completed Step 1.\nBeginning Step 2...\n";
system("bashclean"); # values will be stored in file2.csv

# STEP 3 - combine processed messagelist2.csv entries with corresponding contactlist.csv entries
print "Completed Step 2.\nBeginning Step 3...\n";

# create alltextsforclassdef.csv file and append the column headers
open(NEWFILE, ">>alltextsforclassdef.csv");
print NEWFILE "Phone,Date Message Sent,Phone Number Added to DNC List Date,Message,Status,Phone,First Name,Last Name,Age,State\n";
close NEWFILE;

# open the csv file for reading
open(MSGDATA, 'file2.csv') or die "Unable to read file2.csv.";

while(<MSGDATA>)
{
	# store each 'column' as a seperate value in the array using ',' as the delimiter
	@classcase = split(',', $_);

	# save the phone number from file2.csv in a variable
	$phonenum=$classcase[0];

	# open contactlist.csv file
	open(CONDATA, 'contactlist.csv') or die "Unable to read contactlist.csv.";

	while(<CONDATA>)
	{
		# store each 'column' as a seperate value in the array using ',' as the delimiter
		@classcontact = split(',', $_);

		# save the phone number from the contactlist.csv file in a variable
		$contactnum=$classcontact[0];

		# compare the phone number from contactlist.csv to the processed phone number in file2.csv, if they are equal, proceed to combine the values
		if ($contactnum eq $phonenum)
		{
			$recordline = join( ",", "$classcase[0]", "$classcase[1]", "$classcase[2]", "$classcase[3]", "$classcase[4]", "$classcontact[0]", "$classcontact[1]", "$classcontact[2]", "$classcontact[3]", "$classcontact[4]" );
			$recordline =~ s/\n//g; # remove newline
			open(FINAL, ">>alltextsforclassdef.csv");
			print FINAL "$recordline\n";
			close FINAL;
		}
	}
}
close MSGDATA;
