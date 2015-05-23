ESOAutoRecharge v2.0.0
=============

An addon for The Elder Scrolls Online which recharges and repairs your equipped weapons and amour automatically upon entering and leaving combat. 
A single soul gem will be consumed per weapon recharged in the order of worst to best (e.g lesser soul gems will be used before common).
A single repair kit will be consumed per piece of armour recharged in the order of worst to best (e.g common repair kits will be used before greater).

Installation
=============

1. [Download the latest version](https://raw.githubusercontent.com/XanDDemoX/ESOAutoRecharge/master/zips/Auto%20Recharge%202.0.0.zip)
2. Extract or copy the "Recharge" folder into your addons folder:

"Documents\Elder Scrolls Online\live\Addons"

"Documents\Elder Scrolls Online\liveeu\Addons"

For example:

"Documents\Elder Scrolls Online\live\Addons\Recharge"

"Documents\Elder Scrolls Online\liveeu\Addons\Recharge"

Usage
=============
**Automatic Charge**
* /rc 		- Attempts to recharge the currently equipped primary and secondary weapons. 
* /rc on  	- Enable automatic equipped weapons recharging.
* /rc +
* /rc off 	- Disable automatic equipped weapons recharging.
* /rc -
* /rc 0-99  - Set the minimum charge percentage

**Automatic Repair**
* /rp - Attempts to repair the currently equipped armour. 
* /rp on - Enable automatic amour repairing. 
* /rp +
* /rp off - Disable automatic armour repairing. 
* /rp -
* /rp 0-99  - Set the minimum condition percentage

Change Log
=============
* **Version 2.0.0**
  * Implemented Automatic amour repair
  * Fixed potentially not searching all bag slots for items.
* **Version 1.0.7**
  * Fixed missing local definition in master weapon exclusion.
* **Version 1.0.6**
  * Added check of whether the player is dead before attempting to recharge.
  * Added fixed Master weapon exclusion.
* **Version 1.0.5**
  * Increased settings version.
* **Version 1.0.4**
  * Restored original settings variable name
* **Version 1.0.3**
  * Moved Readme and Licence into Recharge folder within zip for users who use Minion. 
* **Version 1.0.2**
  * Disabled master weapon exclusion.
* **Version 1.0.1**
  * Added master weapon exclusion.
* **Version 0.0.6**
  * Added string trim to input to remove whitespace before attempting to parse a potentially numeric input
* **Version 0.0.5**
  * Enabled setting of a minimum charge percentage.
* **Version 0.0.4**
  * Initial Release

DISCLAIMER
=============
THIS ADDON IS NOT CREATED BY, ENDORSED, MAINTAINED OR SUPPORTED BY ZENIMAX OR ANY OF ITS AFFLIATES.
