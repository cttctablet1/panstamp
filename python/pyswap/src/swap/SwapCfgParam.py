#########################################################################
#
# SwapCfgParam
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
__date__  ="$Aug 26, 2011 8:56:27 AM$"
#########################################################################

from swap.SwapDefs import SwapType
from swap.SwapParam import SwapParam

class SwapCfgParam(SwapParam):
    """
    Class representing a configuration parameter for a given mote
    """

    def __init__(self, register=None, pType=SwapType.NUMBER, name="",
                position="0", size="1", default=None, verif=None):
        """
        Class constructor

        @param register: Register containing this parameter
        @param pType: Type of SWAP endpoint (see SwapDefs.SwapType)
        @param direction: Input or output (see SwapDefs.SwapType)
        @param name: Short name about the parameter
        @param description: Short description about hte parameter
        @param position: Position in bytes.bits within the parent register
        @param size: Size in bytes.bits
        @param default: Default value in string format
        @param verif: Verification string
        """
        SwapParam.__init__(self, register, pType, None, name, position, size, default, verif)
        ## Default value
        self.default = default