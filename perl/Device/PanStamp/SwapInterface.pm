###########################################################
# SWAP Interface superclass. Any SWAP application should derive from this one
###########################################################

package Device::PanStamp::SwapInterface;

use strict;
use warnings;

use parent qw(Exporter);
our @EXPORT_OK = qw();    # symbols to export on request

use Device::PanStamp::SwapServer;

###########################################################
# sub swapServerStarted
#
# SWAP server started successfully
###########################################################

sub swapServerStarted() {

}

###########################################################
# sub swapPacketReceived
#
# New SWAP packet received
#
# @param packet: SWAP packet received
###########################################################

sub swapPacketReceived($) {

}

###########################################################
# sub swapPacketSent
#
# SWAP packet transmitted
#
# @param packet: SWAP packet transmitted
###########################################################

sub swapPacketSent($) {

}

###########################################################
# sub newMoteDetected($)
#
# New mote detected by SWAP server
#
# @param mote: mote detected
###########################################################

sub newMoteDetected($) {

}

###########################################################
# sub newParameterDetected
#
# New configuration parameter detected by SWAP server
#
# @param parameter: Endpoint detected
###########################################################

sub newParameterDetected($) {

}

###########################################################
# sub newEndpointDetected
#
# New endpoint detected by SWAP server
#
# @param endpoint: Endpoint detected

###########################################################

sub newEndpointDetected($) {

}

###########################################################
# sub moteStateChanged
#
# Mote state changed
#
# @param mote: Mote having changed
###########################################################

sub moteStateChanged($) {

}

###########################################################
# sub moteAddressChanged
#
# Mote address changed
#
# @param mote: Mote having changed
###########################################################

sub moteAddressChanged($) {

}

###########################################################
# sub registerValueChanged
#
# Register value changed
#
# @param register: Register having changed
###########################################################

sub registerValueChanged($) {

}

###########################################################
# sub endpointValueChanged
#
# Endpoint value changed
#
# @param endpoint: Endpoint having changed
###########################################################

sub endpointValueChanged($) {

}

###########################################################
# sub parameterValueChanged
#
# Configuration parameter changed
#
# @param parameter: configuration parameter having changed
###########################################################

sub parameterValueChanged($) {

}

###########################################################
# sub getNbOfMotes
#
# @return the amount of motes available in lstMotes
###########################################################

sub getNbOfMotes() {

}

###########################################################
# sub getMote
#
# Return mote from list
#
# @param index: Index of the mote within lstMotes
# @param address: SWAP address of the mote
# @return mote
###########################################################

sub getMote(;$$) {
  my ( $self, $index, $address ) = @_;
  return $self->{server}->{network}->get_mote( $index, $address );
}

###########################################################
# sub setMoteRegister
#
# Set new register value on wireless mote
#
# @param mote: Mote targeted by this command
# @param regId: Register ID
# @param value: New register value
#
# @return True if the command is correctly ack'ed. Return False otherwise
###########################################################

sub setMoteRegister($$$) {
  my ( $self, $mote, $regId, $value ) = @_;
  return $self->{server}->setMoteRegister( $mote, $regId, $value );
}

###########################################################
# sub queryMoteRegister
#
# Query mote register, wait for response and return value
#
# Non re-entrant method!!
#
# @param mote: Mote to be queried
# @param regID: Register ID
# @return register value
###########################################################

sub queryMoteRegister($$) {
  my ( $self, $mote, $regId ) = @_;
  return $self->{server}->queryMoteRegister( $mote, $regId );
}

###########################################################
# sub create_server
#
# Create server object
###########################################################

sub create_server(;$) {
  my ( $self, $settings ) = @_;
  $self->{server} =
    Device::PanStamp::SwapServer->new( $self, $settings );
  return $self->{server};
}

###########################################################
# sub start_server
#
# Start SWAP server
#
# @param async: if 1 run a separate thread to receive messages from SerialModem. Defaults to 0.
###########################################################

sub start_server(;$) {
  my ( $self, $async ) = @_;
  $self->{server}->start($async);
}

###########################################################
# sub poll_server
#
# Poll SWAP server (if not running async)
###########################################################

sub poll_server() {
  my $self = shift;
  $self->{server}->poll();
}

###########################################################
# sub stop
#
# Stop SWAP server
###########################################################

sub stop() {
  my $self = shift;
  $self->{server}->stop();
}

###########################################################
# sub attach_port()
#
# Attach SWAP server to SerialPort-object and start.
#
# @param serport: reference to existing Device::SerialPort or Win32::SerialPort object
# @param async: if 1 run a separate thread to handle serial port. Defaults to 0.
###########################################################

sub attach_port($;$) {
  my ( $self, $serport, $async ) = @_;

  $self->{server}->attach($serport,$async);
}

###########################################################
# sub get_endpoint
#
# Get endpoint given its unique id or location.name pair
#
# @param endpid endpoint id
# @param location endpoint location
# @param name endpoint name
#
# @return endpoint object
###########################################################

sub get_endpoint(;$$$) {
  my ( $self, $endpid, $location, $name ) = @_;
  foreach my $mote ( @{ $self->{network}->{motes} } ) {
    foreach my $register ( @{ $mote->{regular_registers} } ) {
      foreach my $endpoint ( @{ $register->{parameters} } ) {
        if (
          ( defined $endpid and $endpid eq $endpoint->{id} )
          or (  defined $name
            and defined $location
            and $name eq $endpoint->{name}
            and $location eq $endpoint->{location} )
          )
        {
          return $endpoint;
        }
      }
    }
  }
  return undef;
}

###########################################################
# sub update_definition_files
#
# Update Device Definition Files from Internet server
###########################################################

sub update_definition_files() {
  my $self = shift;
  $self->{server}->update_definition_files();
}

###########################################################
# sub new
#
# Class constructor
#
# @param settings: path to the main configuration file
# @param verbose: Print out SWAP frames
# @param start: Start SWAP server if True
###########################################################

sub new(;$$) {
  my ( $class, $settings, $start, $async ) = @_;

  ## SWAP server
  my $self = bless {}, $class;

  if ($start) {
    print "SWAP server starting...\n";
    $self->{server} =
      Device::PanStamp::SwapServer->new( $self, $settings, $start, $async );
    $self->{network} = $self->{server}->{network};
    if ($start) {
      print "SWAP server is now running...\n";
    }
  }
  return $self;
}

1;
