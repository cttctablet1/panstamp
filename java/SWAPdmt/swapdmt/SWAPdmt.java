/**
 * SWAPdmt.java
 *
 * Copyright (c) 2011 Daniel Berenguer <dberenguer@usapiens.com>
 *
 * This file is part of the panStamp project.
 *
 * panStamp  is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * any later version.
 *
 * panLoader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with panLoader; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
 * USA
 *
 * Author: Daniel Berenguer
 * Creation date: 04/01/2011
 */

package swapdmt;

import device.DeviceEventHandler;
import device.SwapGateway;
import swap.SwapEndpoint;
import swap.SwapMote;
import ccexception.CcException;
import swap.SwapDefs;
import xmltools.XmlException;


/**
 * SWAPdmt class
 *
 * Main class for the SWAP device managing tool
 */
public class SWAPdmt implements DeviceEventHandler
{
  /**
   * Configuration file for wireless parameters
   */
  private final static String configWirelessFile = "wireless.xml";

  /**
   * Main GUI window
   */
  private SWAPdmtView view;

  /**
   * SWAP gateway
   */
  private SwapGateway swapGateway;

  /**
   * True if the there is connection to the serial gateway
   */
  private boolean isConnected = false;
  
  /**
   * Class constructor
   */
  public SWAPdmt(SWAPdmtView view)
  {
    this.view = view;
    this.view.setSWAPdmtObj(this);

    try
    {
      swapGateway = new SwapGateway(this);
    }
    catch (CcException ex)
    {
      ex.print();
    }
  }

  /**
   * connect
   *
   * Start SWAP comms
   */
  public void connect()
  {
    try
    {
      swapGateway.connect();
      isConnected = true;
    }
    catch (CcException ex)
    {
      ex.print();
    }
  }

  /**
   * disconnect
   *
   * Disconnect SWAP comms
   */
  public void disconnect()
  {
    try
    {
      swapGateway.disconnect();
      isConnected = false;
    }
    catch (CcException ex)
    {
      ex.print();
    }
  }

  /**
   * isConnected
   *
   * SWAP connection successfully running
   */
  public boolean isConnected()
  {
    return isConnected;
  }

  /**
   * updateMoteList
   *
   * Update list of motes
   */
  public void updateMoteList()
  {
    view.clearMoteList();

    SwapMote swapMote;
    int i;

    for(i=0 ; i<swapGateway.getNbOfMotes() ; i++)
    {
      swapMote = swapGateway.getMoteFromIndex(i);
      view.addMoteToList(swapMote);
    }
  }

  /**
   * newMoteDetected
   *
   * New mote detected in the wireless network
   *
   * 'mote'	New wireless mote
   */
  public void newMoteDetected(SwapMote mote)
  {
    updateMoteList();
  }

  /**
   * moteAddressChanged
   *
   * Address changed on the mote passed as argument
   *
   * 'mote'	Wireless mote
   */
  public void moteAddressChanged(SwapMote mote)
  {
    updateMoteList();
  }

  /**
   * moteStateChanged
   * 
   * System state changed on the mote passed as argument
   * 
   * 'mote'	Wireless mote
   */
  public void moteStateChanged(SwapMote mote)
  {
     // Get mote address
    int devAddr = mote.getAddress();
    // State = SYNC mode?
    if (mote.getState() == SwapDefs.SYSTATE_SYNC)
      view.syncReceived(devAddr);
  }

  /**
   * newEndpointDetected
   *
   * New endpoint detected in the wireless network
   *
   * 'endpoint'	New endpoint
   */
  public void newEndpointDetected(SwapEndpoint endpoint)
  {

  }

  /**
   * endpointValueChanged
   *
   * Reports endpoint value event
   *
   * 'endpoint'	Endpoint having changed its value
   */
  public void endpointValueChanged(SwapEndpoint endpoint)
  {
  }

  /**
   * getMote
   *
   * Get SWAP mote given its index
   *
   * 'index'  Index of the mote
   */
  public SwapMote getMote(int index)
  {
    return swapGateway.getMoteFromIndex(index);
  }

  /**
   * getMoteFromAddress
   *
   * Get SWAP mote given its device address
   *
   * 'index'  Index of the mote
   */
  public SwapMote getMoteFromAddress(int devAddr)
  {
    return swapGateway.getMoteFromAddress(devAddr);
  }

  /**
   * removeMote
   *
   * Remove SWAP mote from list
   *
   * 'index'  Index of the mote to be removed
   */
  public void removeMote(int index)
  {
    swapGateway.removeMote(index);
  }

  /**
   * getMoteManufacturer
   *
   * Return the manufacturer string of the mote with the address passed as argument
   *
   * 'devAddr'  Device address of the mote
   */
  public String getMoteManufacturer(int devAddr)
  {
    SwapMote mote = this.swapGateway.getMoteFromAddress(devAddr);

    return mote.getManufacturer();
  }

  /**
   * getMoteProduct
   *
   * Return the product string of the mote with the address passed as argument
   *
   * 'devAddr'  Device address of the mote
   */
  public String getMoteProduct(int devAddr)
  {
    SwapMote mote = this.swapGateway.getMoteFromAddress(devAddr);

    return mote.getProduct();
  }

  /**
   * setDevAddress
   *
   * Set device address of the serial gateway
   *
   * 'address'    SWAP address of the serial gateway
   */
  public boolean setDevAddress(int address)
  {
    try
    {
      return swapGateway.setDevAddress(address);
    }
    catch (CcException ex)
    {
      ex.print();
    }
    return false;
  }

  /**
   * setNetworkParams
   *
   * Configure network parameters in all motes available
   *
   * 'freqChannel'  Frequency channel
   * 'netId'        Network id
   * 'secu'         Security option
   *
   * Return true if the functions completes successfully
   * Return false otherwise
   */
  public boolean setNetworkParams(int freqChannel, int netId, int secu)
  {
    boolean res = true;

    try
    {
      if (!swapGateway.setFreqChannel(freqChannel))
        res = false;
      if (!swapGateway.setNetId(netId))
        res = false;
      if (!swapGateway.setSecurity(secu))
        res = false;
    }
    catch (CcException ex)
    {
      ex.print();
    }
    return res;
  }

  /**
   * getGatewayAddress
   *
   * Get gateway (device) address
   */
  public int getGatewayAddress()
  {
    return swapGateway.getAddress();
  }

  /**
   * getNetworkId
   *
   * Get the network ID programmed into the serial gateway
   */
  public int getNetworkId()
  {
    return swapGateway.getNetId();
  }

  /**
   * getFreqChannel
   *
   * Get the frequency channel programmed into the serial gateway
   */
  public int getFreqChannel()
  {
    return swapGateway.getFreqChannel();
  }

  /**
   * getSecurityOpt
   *
   * Get security option from XML file
   */
  public int getSecurityOpt()
  {
    return swapGateway.getSecurity();
  }

  /**
   * getPortName
   *
   * Get the name/path of the serial port
   */
  public String getPortName()
  {
    return swapGateway.getSerialPort();
  }

  /**
   * getPortSpeed
   *
   * Get the baud rate (bps) of the serial port
   */
  public int getPortSpeed()
  {
    return swapGateway.getSpeed();
  }

  /**
   * setSerialParams
   *
   * Set serial parameters
   *
   * 'port'	Name/path of the serial port
   * 'speed'	Serial baud rate
   */
  public void setSerialParams(String port, int speed)
  {
    try
    {
      swapGateway.setSerialParams(port, speed);
    }
    catch (XmlException ex)
    {
      ex.print();
    }
  }
}
