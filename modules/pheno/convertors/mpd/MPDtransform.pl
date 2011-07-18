#!/usr/bin/env perl

=head1 NAME

MPDTransform

=head1 SYNOPSIS

Transform from Mouse Phenome Database internal format to MOLGENIS tab delimited import

=cut

use strict;
use warnings;

use Text::CSV_XS;
use Data::Dumper;
# use Term::ProgressBar;

=head1 DESCRIPTION

=head2 Function list

=over

=item main()

Main function. Nothing fancy. 

=cut

sub main() {

	# Print usage
	usage();

	# Declare object that will hold the structure
	my %datapoint   = ();
	my %measurement = ();

	# load data into respective hashes
	load_measurements( \%measurement );
	load_animaldatapoints( \%datapoint, \%measurement );

	# write data to molgenis import format
	write_ontology_term( \%datapoint, \%measurement );
	write_investigation( \%datapoint, \%measurement );
	write_individual_panel( \%datapoint, \%measurement );
	write_observablefeature( \%datapoint, \%measurement );
	write_observedvalue( \%datapoint, \%measurement );
	write_protocol( \%datapoint, \%measurement );

	exit 0;
}

=item usage()

Prints script usage. 

=cut

sub usage() {
	print <<'USAGE';
Usage:   MPDTransform.pl

Brief summary:

Transform from Mouse Phenome Database internal format to MOLGENIS tab delimited import

USAGE
}

=item transform_files()

Opens appropriate filehandles

=cut

sub write_protocol($$) {
	my ( $datapoint_ref, $meas_ref, ) = @_;
	local $\ = "\n";    # do the magic of println

	# load protocols into respective hashes
	my $prot;
	my $feat;
	my $protocol_projsym;

	while ( my ( $mesnum, $meas ) = each(%$meas_ref) ) {
        {
	        no warnings 'uninitialized';

			# create a tree		
			$prot->{ $meas->{projsym} . '-'. $meas->{cat1} }->{ $meas->{projsym} . '-'.$meas->{cat2} }->{ $meas->{projsym} . '-'.$meas->{cat3} } = undef;
			
			# keep the values
			$protocol_projsym ->{ $meas->{projsym} . '-'. $meas->{cat1} }->{projsym} = $meas->{projsym} if defined $meas->{cat1};
			$protocol_projsym ->{ $meas->{projsym} . '-'. $meas->{cat1} }->{prot_name} = $meas->{cat1} if defined $meas->{cat1};
			$protocol_projsym ->{ $meas->{projsym} . '-'. $meas->{cat2} }->{projsym} = $meas->{projsym} if defined $meas->{cat2};
			$protocol_projsym ->{ $meas->{projsym} . '-'. $meas->{cat2} }->{prot_name} = $meas->{cat2} if defined $meas->{cat2};
			$protocol_projsym ->{ $meas->{projsym} . '-'. $meas->{cat3} }->{projsym} = $meas->{projsym} if defined $meas->{cat3};
			$protocol_projsym ->{ $meas->{projsym} . '-'. $meas->{cat3} }->{prot_name} = $meas->{cat3} if defined $meas->{cat3};
			
			# trim empty branches
			if (!defined $meas->{cat3}) {
				delete $prot->{ $meas->{projsym} . '-'. $meas->{cat1} }->{ $meas->{projsym} . '-'.$meas->{cat2} }->{ $meas->{projsym} . '-'.$meas->{cat3} };
			}
			if (!defined $meas->{cat2})
			{
				delete $prot->{ $meas->{projsym} . '-'. $meas->{cat1} }->{ $meas->{projsym} . '-'. $meas->{cat2} } ;
			}
			
			
			# add observablefeatures
			if (defined $meas->{cat3}){
				$feat->{ $meas->{cat3} }->{ $meas->{desc} }++;
			}
			elsif (defined $meas->{cat2}){
				$feat->{ $meas->{cat2} }->{ $meas->{desc} }++;
			}
			else{
				$feat->{ $meas->{cat1} }->{ $meas->{desc} }++;
			}
        }
	}
		
	print Dumper($prot);
	print Dumper($protocol_projsym);
	
	# write protocols
	open my $fh1, ">:utf8", "../../../data/MPD/protocol.txt" or die "$!";
	open my $fh2, ">:utf8", "../../../data/MPD/protocol_protocolComponents.txt" or die "$!";
	open my $fh3, ">:utf8", "../../../data/MPD/protocol_observableFeatures.txt" or die "$!";

	# write headers
	print $fh1 join (
		"\t",
		qw/name investigation_name protocolComponents_name/
	);
	print $fh2 join (
		"\t",
		qw/protocol_name protocol_self_name/
	);
	print $fh3 join (
		"\t",
		qw/protocol_name observableFeature_name/
	);
	
	# walk the tree write protocol and protocolcomponents
	while ( my ( $name1, $prot2 ) = each(%$prot) ) {
		my @comps2;
		while ( my ( $name2, $prot3 ) = each(%$prot2) ) {
			push @comps2, $name2;
			my @comps3;
			for my $name3 (keys %$prot3) {
				push @comps3, $name3;
				print $fh1 join ( "\t", $protocol_projsym->{$name3}->{prot_name}, $protocol_projsym->{$name3}->{projsym});
				print $fh2 join ( "\t", $protocol_projsym->{$name2}->{prot_name},$protocol_projsym->{$name3}->{prot_name});
				print 'name3 ' . $name3 . ' ' . Dumper($protocol_projsym->{$name3});
			}
			print $fh1 join ( "\t", $protocol_projsym->{$name2}->{prot_name},  $protocol_projsym->{$name2}->{projsym});
			print $fh2 join ( "\t", $protocol_projsym->{$name1}->{prot_name}, $protocol_projsym->{$name2}->{prot_name});
			print 'name2 '. $name2 . ' '. Dumper($protocol_projsym->{$name2});
		}
		print $fh1 join ( "\t", $protocol_projsym->{$name1}->{prot_name},  $protocol_projsym->{$name1}->{projsym});		
	}	

	# walk the tree write protocol_observablefeatures
	while ( my ( $protocolName, $feature ) = each(%$feat) ) {
		for my $featureName (keys %$feature){
			print $fh3 join ( "\t", $protocolName, $featureName);
		}
	} 
	close $fh1;
	close $fh2;
	close $fh3;
}

sub write_observedvalue($$) {
	my ( $datapoint_ref, $meas_ref, ) = @_;
	local $\ = "\n";    # do the magic of println

	open my $fh1, ">:utf8", "../../../data/MPD/observedvalue.txt" or die "$!";

	# write headers
	print $fh1 join (
		"\t",
		qw/measnum observationTarget_name observationTarget_investigation_name observableFeature_name observableFeature_investigation_name investigation_name value/
	);
	my $observationTarget_name;
	my $observableFeature_name;
	my $investigation_name;

	while ( my ( $id, $datapoint ) = each(%$datapoint_ref) ) {
		$observationTarget_name = $datapoint->{animal_id};	
		for my $measnum ( keys %{ $datapoint->{measnum} } ) {		
			$observableFeature_name = $meas_ref->{$measnum}->{varname};
			$investigation_name     = $meas_ref->{$measnum}->{projsym};
			for my $value ( @{ $datapoint->{measnum}->{$measnum} } ) {
				print $fh1 join ( "\t",$measnum,
								  $observationTarget_name, $investigation_name, $observableFeature_name, $investigation_name,
								  $investigation_name, $value );
			}
		}
	}
	close $fh1;

}

sub write_observablefeature($$) {
	my ( $datapoint_ref, $meas_ref, ) = @_;
	local $\ = "\n";    # do the magic of println
	my %unit;           # stores unique units
	open my $fh1, ">:utf8", "../../../data/MPD/observablefeature.txt" or die "$!";

	# write headers
	print $fh1 join ( "\t", qw/name investigation_name description unit_term/ );

	# write the fixed 'sex' and 'species' features which are standard
	# TODO
	
	# write the other features
	while ( my ( $id, $meas ) = each(%$meas_ref) ) {
		print $fh1 join ( "\t", $meas->{varname}, $meas->{projsym}, $meas->{desc}, $meas->{units} );
		$unit{ $meas->{units} }->{term} = $meas->{units};
	}
	close $fh1;

	# add units as ontology terms to file
	open my $fh2, ">>:utf8", "../../../data/MPD/ontologyterm.txt" or die "$!";

	for my $key ( keys %unit ) {

		# headers: name,termLabel,termAccession,termSource_name
		# data: mouse strain,mouse strain,http://www.ebi.ac.uk/efo/EFO_0000607,EFO
		print $fh2 join ( "\t", $unit{$key}->{term}, $unit{$key}->{term}, q{} );
	}
	close $fh2;
}

sub write_individual_panel($$) {
	my ( $datapoint_ref, $meas_ref, ) = @_;
	local $\ = "\n";    # do the magic of println
	my %panels = ();          # store unique panel names

	open my $fh1, ">:utf8", "../../../data/MPD/individual.txt"        or die "$!";
	open my $fh2, ">:utf8", "../../../data/MPD/panel_individuals.txt" or die "$!";

	# write headers
	print $fh1 join ( "\t", qw/name investigation_name/ );
	print $fh2 join ( "\t", qw/panel_name panel_investigation_name individual_name individual_investigation_name/ );

	while ( my ( $name, $animal_ref ) = each(%$datapoint_ref) ) {
		print $fh1 join ( "\t", $animal_ref->{animal_id}, $animal_ref->{projsym} );
		print $fh2 join ( "\t", $animal_ref->{strain}, $animal_ref->{projsym}, $animal_ref->{animal_id}, $animal_ref->{projsym} );
		$panels{ uc($animal_ref->{strain}.'['.$animal_ref->{projsym}.']') }->{strain} = $animal_ref->{strain};
		$panels{ uc($animal_ref->{strain}.'['.$animal_ref->{projsym}.']') }->{projsym} = $animal_ref->{projsym};
	}
	close $fh1;
	close $fh2;

	open my $fh3, ">:utf8", "../../../data/MPD/panel.txt" or die "$!";

	# write header
	print $fh3 join ( "\t", qw/name investigation_name/ );

	while ( my ( $name, $panel) = each %panels ) {
		print $fh3 join ( "\t", $panel->{strain}, $panel->{projsym} );
	}
	close $fh3;
}

sub write_investigation($$) {
	my ( $datapoint_ref, $meas_ref ) = @_;
	local $\ = "\n";    # do the magic of println

	my @output = (
				   [ 'name', 'description','accession' ],
				   [
					  'Mouse Phenome Database',
					  'http://www.jax.org/phenome',
				   ]
	);

	open my $fh_out, ">:utf8", "../../../data/MPD/investigation.txt" or die "$!";
	print $fh_out join ( "\t", qw/name description accession/ );    # write headers

	# create a hash of uniqe project names
	# from measurements available in database
	my %project;
	for my $meas ( keys %$meas_ref ) {
		$project{ $meas_ref->{$meas}->{projsym} }++;
	}

	# load projects name from external file
	# this list was scraped from website and is not complete
	my %project_des        = load_projects();
	my $description_suffix = q{Description not available for this data set downloaded from Mouse Phenome Database};

	for my $name ( keys %project ) {
		print $fh_out join ( "\t", $name, $project_des{$name} || $description_suffix, "http://phenome.jax.org/pub-cgi/phenome/mpdcgi?rtn=projects/details&sym=".$name);
	}
	close $fh_out;
}

sub load_projects() {
	my %project_des;

	my $csv = make_csv_parser();
	open my $fh_in, "<:utf8", "../../../data/MPD/orig/projects.txt" or die "$!";

	# set column names to headers
	$csv->column_names( $csv->getline($fh_in) );

	until ( $csv->eof() ) {
		my $row = $csv->getline_hr($fh_in);
		check_parser_for_errors( \$csv, \$row );
		$project_des{ $row->{name} } = $row->{description};
	}
	close($fh_in);
	return %project_des;
}

sub write_ontology_term($$) {
	my ( $datapoint_ref, $meas_ref ) = @_;
	local $\ = "\n";    # do the magic of println
	
	# create ontology
	# write header
	open my $fh_out, ">:utf8", "../../../data/MPD/ontology.txt"
		  or die "ERROR: Can't open ontology.txt for write. $!";
	print $fh_out join ( "\t", qw/name ontologyAccession/ );
	print $fh_out join ( "\t", 'EFO', 'http://www.ebi.ac.uk/efo');
	close $fh_out;

	# for each ontology add terms
	open $fh_out, ">:utf8", "../../../data/MPD/ontologyterm.txt"
	  or die "ERROR: Can't open ontologyterm.txt for write. $!";
	  
	# header 
	print $fh_out join ( "\t", qw/term termAccession ontology_name/ );
	
	my @ontologyterm = (
						 [
							'mouse strain','http://www.ebi.ac.uk/efo/EFO_0000607', 'EFO'
						 ],
						 [ 'day', 'http://www.ebi.ac.uk/efo/EFO_0001789', 'EFO']
	);

	for my $line (@ontologyterm) {
		print $fh_out join ( "\t", @$line );
	}
	close $fh_out;
}

sub load_animaldatapoints($$) {
	my ( $datapoint_ref, $meas_ref, ) = @_;

	my $csv = make_csv_parser();
	open my $fh_in, "<:utf8", "../../../data/MPD/orig/animaldatapoints.txt"
	  or die "ERROR: Can't load animaldatapoints.txt. $!";

	# set column names to headers
	$csv->column_names( $csv->getline($fh_in) );

	my $c;
#	my $progress = Term::ProgressBar->new(
#										   {
#											 count  => 548912,
#											 name   => 'Loading datapoints',
#											 ETA    => 'linear',
#											 remove => 0,
#										   }
#	);
#	$progress->max_update_rate(2);
	my %warning;     # stores measnum that warning was already printed for
	my %animalid;    # stores animalids for consistency checking
	my %measid;		 # stores measurements that have values for consistency checking
	my %measdesc;    # stores measurements descriptions for consistensy checking

	until ( $csv->eof() ) {
		my $row = trim_row($csv->getline_hr($fh_in));
		check_parser_for_errors( \$csv, \$row );
#		$progress->update( $c++ );
		print $c . ' out of 548912' . "\n" if $c++ % 1000 == 0;
		if ( exists( $meas_ref->{ $row->{measnum} } ) ) {
			# TODO WHAT ABOUT MISSING VALUES
			if ( defined( $row->{value} ) ) {

				$animalid{ uc( $row->{'animal_id'} ) }->{ $row->{'animal_id'} }++;
				$measid{ $row->{measnum} }++;
				$warning{
					"CAPITALISATION: $row->{'animal_id'} inconsistent in animaldatapoints.txt\n" }++
				  if scalar keys %{ $animalid{ uc( $row->{'animal_id'} ) } } > 1;
				my $projsym = $meas_ref->{ $row->{measnum} }->{projsym};
				my $individual_name = uc ($row->{'strain'} . '[' .  $row->{'animal_id'} . '][' . $projsym . ']');
				
				# animal_id = {strain} + {animalid}
				# it turns out animals are numbered per strain
				
				$datapoint_ref->{ $individual_name }->{sex} = 'male'
				  if lc( $row->{sex} ) eq 'm';
				$datapoint_ref->{ $individual_name }->{sex} = 'female'
				  if lc( $row->{sex} ) eq 'f';
				 if (defined $datapoint_ref->{ $individual_name }->{animal_id}
				 && $datapoint_ref->{ $individual_name }->{animal_id} ne uc($row->{strain} . "-" . $row->{animal_id} )) {
					print "ERROR MULTIPLE ANIMAL IDs per ANIMAL?" . $individual_name . " " 
					. $datapoint_ref->{ $individual_name }->{animal_id} . " " . $row->{strain} . "-" . $row->{animal_id} . "\n";
				  }
				$datapoint_ref->{ $individual_name }->{animal_id} = uc($row->{strain} . "-" . $row->{animal_id});
				$datapoint_ref->{ $individual_name }->{strain}    = $row->{strain};
				if (defined $datapoint_ref->{ $individual_name }->{projsym}) {
					print "WARNING individual in 2 different investigations! " . $individual_name . " already in " .
					$datapoint_ref->{ $individual_name }->{projsym} . " and " .$projsym . "\n"
					if $datapoint_ref->{ $individual_name }->{projsym} ne $projsym;
				}
				$datapoint_ref->{ $individual_name }->{projsym} = $projsym;
				push @{ $datapoint_ref->{ $individual_name }->{measnum}
					  ->{ $row->{measnum} } }, $row->{value};
			 } else {
				$warning{ "EMPTY VALUE: Line $. in animaldatapoints.txt has an empty value\n" }++;
			}
		} else {
			$warning{
				"MISSING REFERENCE: measnum $row->{measnum} was not found in measurements.txt\n" }++;
		}
	}
	close($fh_in);
	
	# find unmatched measurements (with no values)
	for my $meas ( keys %$meas_ref) {
		$measdesc{ uc( $meas_ref->{$meas}->{desc} ) }->{ $meas } ++;
		$warning{"MEASUREMENT MISSING: $meas $meas_ref->{$meas}->{desc} in animaldatapoints.txt\n" }++
				  if !defined $measid{$meas};
	}
	# find similiar measurements by description
	for my $meas ( keys %$meas_ref) {
		$warning{"DUPLICATE MEASUREMENTS: $meas_ref->{$meas}->{desc} (measnum $meas)\n" }++		
		if scalar keys %{$measdesc{ uc( $meas_ref->{$meas}->{desc} ) }} > 1;		
	}

	# print accumulated warnings
	for my $msg ( sort( keys %warning ) ) {
		print $msg;
	}
}

sub load_measurements($) {
	my $meas_ref = shift;

	my $csv = make_csv_parser();
	open my $fh_in, "<:utf8", "../../../data/MPD/orig/measurements.txt"
	  or die "ERROR: Can't load measurements.txt. $!";

	# set column names to headers
	$csv->column_names( $csv->getline($fh_in) );

	my $c;
#	my $progress = Term::ProgressBar->new(
#										   {
#											 count  => 1806,
#											 name   => 'Loading measurements',
#											 ETA    => 'linear',
#											 remove => 0,
#										   }
#	);

	until ( $csv->eof() ) {
		my $row = trim_row($csv->getline_hr($fh_in));
		check_parser_for_errors( \$csv, \$row );
		# assign variables
		$meas_ref->{ $row->{measnum} }->{varname}    = $row->{varname};
		$meas_ref->{ $row->{measnum} }->{desc}    = $row->{desc};
		$meas_ref->{ $row->{measnum} }->{units}   = $row->{units};
		$meas_ref->{ $row->{measnum} }->{projsym} = $row->{projsym};
		$meas_ref->{ $row->{measnum} }->{cat1}    = $row->{cat1} if $row->{cat1} ne '=';
		$meas_ref->{ $row->{measnum} }->{cat2}    = $row->{cat2} if $row->{cat2} ne '=';
		$meas_ref->{ $row->{measnum} }->{cat3}    = $row->{cat3} if $row->{cat3} ne '=';

#		$progress->update( $c++ );
	}
	close($fh_in);
	
	remove_dup_measurements($meas_ref);
	
}

sub trim_row ($){
	my $row = shift;
	local $\ = "\n";    # do the magic of println
	
	for my $key (keys %$row){
		if (defined $row->{$key} && $row->{$key} =~ s/\s{2,}//){
			print "TRIMMING $row->{$key}";
		}
		if (defined $row->{$key} && $row->{$key} =~ s/^\s+//){
			print "TRIMMING $row->{$key}";
		}
		if (defined $row->{$key} && $row->{$key} =~ s/\s+$//){
			print "TRIMMING $row->{$key}";
		} 
	}
	
	return $row;
}

sub remove_dup_measurements($) {
	my $meas_ref = shift;
	
	my (%word_count, %warning);
	# find duplicates, by storing path to branch in a hash
	# if multiple paths are found, the term is duplicated in different places
	while ( my ( $key, $meas ) = each %$meas_ref ) {
		 $word_count{ $meas->{cat1} }->{ROOT}++ if defined $meas->{cat1};
		 $word_count{ $meas->{cat2} }->{ $meas->{cat1} }++ if defined $meas->{cat2};
		 $word_count{ $meas->{cat3} }->{ $meas->{cat1}.$meas->{cat2} }++ if defined $meas->{cat3};
	}
	
	# concatenate to previous cat
	while ( my ( $key, $meas ) = each %$meas_ref ) {
		$meas->{units} = 'N' if $meas->{units} eq 'n';
	
		if ( defined $meas->{cat2} && scalar keys %{$word_count{ $meas->{cat2} }} > 1 ){
			my $no = scalar keys %{$word_count{ $meas->{cat2} }};
			$warning{"DUPLICATE CATEGORY: prefixing $meas->{cat2} with $meas->{cat1} ($no) \n" }++;
			$meas->{cat2} = $meas->{cat1} . ' ' . $meas->{cat2};
		}
		if ( defined $meas->{cat3} && scalar keys %{$word_count{ $meas->{cat3} }} > 1 ){
			my $no = scalar keys %{$word_count{ $meas->{cat3} }};
			$warning{"DUPLICATE CATEGORY: prefixing $meas->{cat3} with $meas->{cat2} ($no) \n" }++;
			$meas->{cat3} = $meas->{cat2} . ' ' . $meas->{cat3};
		}
	}

	# print accumulated warnings
	for my $msg ( sort( keys %warning ) ) {
		print $msg;
	}
	
}

sub make_csv_parser {
	my $csv = Text::CSV_XS->new(
		{
		   sep_char    => qq{\t},
		   quote_char  => qq{"},    # default
		   escape_char => qq{"},    # default
		   binary      => 1,

		   # modified settings below
		   blank_is_undef     => 1,
		   allow_loose_quotes => 1,
		}
	);
}

sub check_parser_for_errors {
	my ( $csv_ref, $row_ref ) = @_;
	if ( !( defined $$row_ref ) and !( $$csv_ref->eof() ) ) {
		my $bad_argument = $$csv_ref->error_input();    # get the most recent bad argument
		my $diag         = $$csv_ref->error_diag();
		print "WARNING: CSV parser error <$diag> on line - $bad_argument.\n";
	}
}

=back

=cut

=head1 AUTHOR

Tomasz Adamusiak 2009

=cut

main();
