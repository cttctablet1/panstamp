###########################################################
# Main configuration settings: config files and directories
###########################################################

package Device::PanStamp::swap::xmltools::XmlSettings;

use strict;
use warnings;

use File::Spec::Functions;
use File::Basename;
use XML::Simple qw(:strict);

###########################################################
# sub read(self):
#
# Read configuration file file
############################################################

sub read() {
  my $self = shift;

  my $tree;

  # Parse XML file
  eval {
    $tree =
      XMLin( $self->{file_name}, ForceArray => [], KeyAttr => [] );
  };
  if ($@) {
    if ( defined $self->{file_name} ) {
      print "Unable to read settings from $self->{file_name}. Reason is: $@\n";
    } else {
      print "unable to read settings. Reason is: undefined filename.\n";
    }
  }

  return unless $tree;

  $self->{debug} = $tree->{debug} if defined $tree->{debug};

  # Get "devices" folder
  if ( my $devices = $tree->{devices} ) {
    $self->{device_localdir} = $devices->{local}  if defined $devices->{local};
    $self->{device_remote}   = $devices->{remote} if defined $devices->{remote};
    $self->{update_def}      = $devices->{update} if defined $devices->{update};
  }

  # Get serial config file
  $self->{serial_file} = $tree->{serial} if defined $tree->{serial};

  # Get network config file
  $self->{network_file} = $tree->{network} if defined $tree->{network};

  # Get SWAP network file
  $self->{swap_file} = $tree->{swapnet} if defined $tree->{swapnet};

  # Get path name of the error log file
  $self->{error_file} = $tree->{errlog} if defined $tree->{errlog};
}

###########################################################
# sub save
#
# Save serial port settings in disk
###########################################################

sub save() {
  my $self = shift;
  open FILE, ">", $self->{file_name} or die $!;
  print FILE "<?xml version=\"1.0\"?>\n";
  print FILE "<settings>\n";
  print FILE "\t<debug>" . $self->{debug} . "</debug>\n";
  print FILE "\t<devices>\n";
  print FILE "\t\t<local>" . $self->{device_localdir} . "</local>\n";
  print FILE "\t\t<remote>" . $self->{device_remote} . "</remote>\n";
  print FILE "\t\t<update>" . $self->{updatedef} . "</update>\n";
  print FILE "\t</devices>\n";
  print FILE "\t<serial>" . $self->{serial_file} . "</serial>\n";
  print FILE "\t<network>" . $self->{network_file} . "</network>\n";
  print FILE "\t<swapnet>" . $self->{swap_file} . "</swapnet>\n";
  print FILE "</settings>\n";
  close FILE;
}

###########################################################
# sub new
#
# Class constructor
#
# @param filename: Path to the configuration file
# @param opt: hash-reference containing (optional) properties:
#             device_localdir, serial_file, network_file, swap_file
###########################################################

sub new($;\%) {
  my ( $class, $file_name ) = @_;

  # Name/path of the current configuration file
  $file_name = "settings.xml" unless $file_name;

  my $self = bless {
    ## Name/path of the current configuration file
    file_name => $file_name,
    ## Debug level (0: no debug, 1: print SWAP packets, 2: print SWAP packets and network events)
    debug => 0,
    ## Name/path of the serial configuration file
    serial_file => "serial.xml",
    ## Name/path of the wireless network configuration file
    network_file => "network.xml",
    ## Name/path of the SWAP net status/config file
    swap_file => "swapnet.json",
    ## Directory where all device config files are stored
    device_localdir => undef,
    ## Remote Devide Definition folder for updates
    device_remote => "http://panstamp.googlecode.com/files/devices.tar",
    ## Automatic udate of local Device Definition folder from internet server
    ## on start-up
    updatedef => 0,
    ## Name/path of the error log file
    error_file => "swap.err"
  }, $class;

  # Read XML file
  $self->read();

  my $direc = dirname($file_name);

  # Convert to absolute paths
  $self->{device_localdir} =
    defined( $self->{device_localdir} )
    ? catfile( $direc, $self->{device_localdir} )
    : $direc;
  $self->{serial_file} =
    defined( $self->{serial_file} )
    ? catfile( $direc, $self->{serial_file} )
    : $direc;
  $self->{network_file} =
    defined( $self->{network_file} )
    ? catfile( $direc, $self->{network_file} )
    : $direc;
  $self->{swap_file} =
    defined( $self->{swap_file} )
    ? catfile( $direc, $self->{swap_file} )
    : $direc;

  return $self;
}

1;
