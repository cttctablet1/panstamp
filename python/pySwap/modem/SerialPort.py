#########################################################################
#
# SerialPort
#
# Copyright (c) 2011 Daniel Berenguer <dberenguer@usapiens.com>
#
# This file is part of the panStamp project.
#
# panStamp  is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# panStamp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with panLoader; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
# USA
#
#########################################################################
__author__="Daniel Berenguer"
__date__ ="$Aug 21, 2011 17:05:27 AM$"
#########################################################################

from swapexception.SwapException import SwapException

import threading
import serial
import time

class SerialPort(threading.Thread):
    """ Wrapper class of the pyserial package """

    def run(self):
        """ Run serial port listener on its own thread """
        if self._serPort is not None:
            if self._serPort.isOpen():
                buffer = []
                # Listen for incoming serial data
                while True:
                    # Read single byte (blocking function)
                    ch = self._serPort.read()
                    # End of serial packet?
                    if ch == '\r' or ((ch == '(') and (len(buffer) > 0)):
                        strBuf = "".join(buffer)
                        buffer = []

                        # Enable for debug only
                        if self._verbose == True:
                            print "Rved: " + strBuf
                        
                        # Notify reception
                        if self.serialReceived is not None:
                            self.serialReceived(strBuf)
                    elif ch != '\n':
                        # Append char at the end of the buffer (list)
                        buffer.append(ch)
            else:
                raise SwapException("Unable to read serial port " + self.portName + " since it is not open")
        else:
            raise SwapException("Unable to read serial port " + self.portName + " since it is not open")

    
    def stop(self):
        """ Stop serial port"""
        if self._serPort is not None:
            if self._serPort.isOpen():
                self._serPort.close()
                

    def send(self, buffer):
        """ Send string buffer via serial """
        # Send serial packet
        self._serPort.write(buffer)
        # Enable for debug only
        if self._verbose == True:
            print("Sent: " + buffer)

    def setRxCallback(self, cbFunction):
        """ Set callback reception function """
        self.serialReceived = cbFunction


    def reset(self):
        """ Hardware reset serial modem """
        # Set DTR line
        self._serPort.setDTR(True)
        time.sleep(0.1)
        # Clear DTR line
        self._serPort.setDTR(False)


    def __init__(self, portName="/dev/ttyUSB0", speed=38400, verbose=False):
        threading.Thread.__init__(self)
        # Name(path) of the serial port
        self.portName = portName
        # Speed of the serial port in bps
        self.portSpeed = speed
        # Serial port object
        self._serPort = None
        # Callback Rx function
        self.serialReceived = None
        # Verbose network traffic
        self._verbose = verbose

        try:
            # Open serial port in blocking mode
            self._serPort = serial.Serial(self.portName, self.portSpeed)
            if self._serPort is None:
                raise SwapException("Unable to open serial port" + self.portName)
            elif not self._serPort.isOpen():
                raise SwapException("Unable to open serial port" + self.portName)
        except serial.SerialException:
            raise SwapException("Unable to open serial port " + self.portName)
