#########################################################################
#
# lagarto-swap
#
# Copyright (c) 2012 Daniel Berenguer <dberenguer@usapiens.com>
#
# This file is part of the lagarto project.
#
# lagarto  is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# lagarto is distributed in the hope that it will be useful,
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
__date__  ="$Jan 29, 2012$"
__appname__= "lagarto-swap"
__version__= "0.0.2"
#########################################################################

from swap.SwapException import SwapException
from swapmanager import SwapManager

from lagartoresources import LagartoException

import sys
import os


if __name__ == '__main__':
  
    settings = os.path.join(os.path.dirname(__file__), "config", "settings.xml")

    try:      
        # SWAP manager
        swap_manager = SwapManager(settings)       
    except SwapException as ex:
        ex.display()
    except LagartoException as ex:
        ex.display()
