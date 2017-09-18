#!/usr/bin/perl 
#====================================================================
# What's this ?
#====================================================================
#
#
# Copyright (C) 2009 Raphaël 'SurcouF' Bordet
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# GPL Licence : http://www.gnu.org/licenses/gpl.txt
#
#====================================================================
# More contributions on http://www.linagora.org
#====================================================================

#====================================================================
# Changelog
#====================================================================
# Version 0.01 (10/12/2009 18:02:21 CET):
# - First implementation
# Author: Raphaël 'SurcouF' Bordet
#====================================================================

use strict;
use warnings;

use Data::Dumper;

use SNMP::Info;

my $info = new SNMP::Info(
		# Auto Discover more specific Device Class
		AutoSpecify	=>	1,
		Debug		=>	1,
		# The rest is passed to SNMP::Session
		DestHost	=>	shift,
	#	Community	=>	'public',
	#	Version		=>	2
		Version		=>	3,
		SecName		=>	'intradef',
		AuthProto	=>	'MD5',
		SecLevel	=>	'authNoPriv',
		AuthPass	=>	shift,
		Context		=>  shift,
	) or die "Can't connect to device.\n";

my $err = $info->error();
die "SNMP Community or Version probably wrong connecting to device. $err\n" if defined $err;

my $name	= $info->name();
my $class	= $info->class();
my $vendor	= $info->vendor();
my $os		= $info->os();
print "SNMP::Info is using this device class : $class\n";

print "Name: $name\n";
print "$vendor ($os)\n";
exit 0;

#print STDERR "DEBUG: info = ". Dumper($info) ."\n";

# Find out the Duplex status for the ports
my $interfaces = $info->ports;
my $ifDescr = $info->i_description();
#for (my $i=1; $i<= $interfaces; $i++ ) {
foreach my $interface ( sort keys %$ifDescr ) {
	print "interface ". $interface .": ". $$ifDescr{$interface} ."\n";
}
#my $i_duplex   = $info->i_duplex();

my $memory = $info->memory_size();
print "memoire : ". Dumper($memory) ."\n"; 

my $hrStorageDescr				= $info->p_descr();
my $hrStorageType				= $info->p_type();
my $hrStorageSize				= $info->p_size();
my $hrStorageUsed				= $info->p_used();
my $hrStorageAllocationUnits	= $info->p_alloc_units();
my $hrFSIndex					= $info->fs_index();
my $hrFSStorageIndex			= $info->fs_p_index();
print "partitions: ". Dumper($hrStorageDescr) ."\n"; 
print "filesystems : ". Dumper($hrFSStorageIndex) ."\n"; 
foreach my $partition ( sort keys %$hrStorageDescr ) {
	print "Partition '". $$hrStorageDescr{$partition} ."':"
#			." type=". SNMP::Info::munge_e_type($$hrStorageType{$partition}) 
			." type=". $$hrStorageType{$partition}
			." size=". $$hrStorageSize{$partition} 
			." used=". $$hrStorageUsed{$partition}
			." unit=". $$hrStorageAllocationUnits{$partition}
			." hrfsindex=". map_fs_index( $hrFSIndex, $partition )
			."\n";

exit 0;

# map hrFSIndex to hrStorageIndex
sub map_fs_index {
    my $hrfsindex		= shift;
    my $partial  		= shift;

    my $fs_index;
    foreach my $iid ( keys %$hrfsindex ) {
        $fs_index{$iid} = $iid;
    }

    return $fs_index;
}

