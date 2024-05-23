#!/usr/bin/perl

# This tool scans all the entries in the JV-LD database to see
# if they are functional or not

use strict;
use warnings;
use Email::Simple;
use Email::Simple::Creator;
use Email::Sender::Simple qw(sendmail);

# No changes below here
my $VERSION="1.1";
my $CONF_FILE="/root/Member_Requests/config.ini";
my $EMAIL_SUBJ="";
my $EMAIL_FROM="";
my $Server_List_File="";
my $email="";
my $SERVER_NAME="";
my $OWNER_EMAIL="";
my $WEBSITE_NAME="";

# Read in configuration options
open(CONF, "<$CONF_FILE") || die("Unable to read config file '$CONF_FILE'");
while(<CONF>)
{
	chop;
	my $FIELD_TYPE = "";
	my $FIELD_VALUE = "";
	($FIELD_TYPE, $FIELD_VALUE) = split (/	/, $_);
	#print("Type is $FIELD_TYPE\n");
	if ($FIELD_TYPE eq "Email_Subj")
	{
		$EMAIL_SUBJ = $FIELD_VALUE;
	}
	elsif ($FIELD_TYPE eq "Email_From")
	{
		$EMAIL_FROM = $FIELD_VALUE;
	}
	elsif ($FIELD_TYPE eq "Server_List_File")
	{
		$Server_List_File = $FIELD_VALUE;
	}
}
close(CONF);

if ($Server_List_File eq "")
{
	print "You have not set a server list file in $CONF_FILE\n";
	exit 1;
}
if ($EMAIL_SUBJ eq "")
{
	print "You have not set a email subject in $CONF_FILE\n";
	exit 1;
}
if ($EMAIL_FROM eq "")
{
	print "You have not set a email sender in $CONF_FILE\n";
	exit 1;
}

# Marks the MUD state and check time
sub SendEmail
{
	my($day, $month, $year)=(localtime)[3,4,5];
	$year += 1900;
	$month += 1;
	$month = substr("0".$month, -2);
	$day = substr("0".$day, -2);
		my $CurBody = <<"END_MESSAGE_BODY";
Dear $OWNER_EMAIL,
 
You have a server with us and we are just checking in to see if you still want this server. If you are still using it you can keep using it. If you no longer want it please let us know so we can remove it. We will be checking in again in another 3 months or so.

Regards,
The $WEBSITE_NAME hosting provider
END_MESSAGE_BODY
		$email = Email::Simple->create(
		header => [
		       From => $EMAIL_FROM,
		       To => $OWNER_EMAIL,
		       Subject => "\[$WEBSITE_NAME\] $EMAIL_SUBJ - $SERVER_NAME",
		],
		body => $CurBody);
		sendmail($email);
}

print("Send Email List ($VERSION)\n");
print("===============================================\n");

open(my $fh, '<:encoding(UTF-8)', $Server_List_File)
  or die "Could not open file '$Server_List_File' $!";
 
while (my $row = <$fh>)
{
	chomp $row;
	# print "$row\n";
	($SERVER_NAME, $OWNER_EMAIL, $WEBSITE_NAME) = split (/	/, $row);
	if (($WEBSITE_NAME eq "") || ($WEBSITE_NAME eq "Unknown"))
	{
		$WEBSITE_NAME = "Pocketmud/Minecity/SynchronetBBS/Citadel";
	}
	print "server name '$SERVER_NAME'\n";
	print "owner email '$OWNER_EMAIL'\n";
	print "website name '$WEBSITE_NAME'\n";
	if ($OWNER_EMAIL eq "foo\@bar.com")
	{
		print "Unknown owner for $SERVER_NAME\n";
		print "---\n";
		next;
	}
	SendEmail();
	print "---\n";
}
close($fh);

exit(0);
