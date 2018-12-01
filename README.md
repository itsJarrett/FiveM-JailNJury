# FiveM-JailNJury
A Jail and Justice System that gives power back to the players.
Copyright (C) 2018  Jarrett Boice

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

---

## Description
FiveM-JailNJury or Jail N' Jury is a advanced jail, and justice system / resource for FiveM servers. Jail N' Jury offer's advanced jail features with a democratic justice system. If a arrestee feels that they have been falsely jailed, they may request a trial by a jury of their peers, the people of your server's state. Fear of arrestees escaping? Have no worry, this is literally impossible. People disconnecting to avoid jail? No problem, the justice system has your back and will jail them upon return!

##  Rundown

### Arrest System
Law Enforcement Officers are able to jail arrestees via the jail command. The arrest is then logged via json and placed into the jailed players file. If the arrestee disconnects, their time is paused at whatever time was remaining when they left the server. When the player reconnects, they are re-jailed for the same time, and charges as prior. The prison is able to detect if a arrestee is attempting to escape and will teleport them back to the jail, it is literally impossible to escape the jail.

### Justice System
An arrestee may only request a court case if their time is longer than 10 minutes. Once the court case has been granted, their jail time is paused and an advertisement is given to all players regarding an upcoming court case. Players are given 5 minutes to make their way to the courthouse for a chance at becoming a juror. A minimum of 3 jurors must be present for the court case to proceed. There is a maximum of 5 jurors. Jurors are selected randomly from players at the courthouse and cannot be any police personnel. Selected jurors are then briefed on the suspect's charges. The arrestee and jurors are then teleported to the court room. The arrestee is given 1 minute to explain their charges to the jurors, at this time the jurors are muted and cannot speak or type. After the 1 minute has passed, the arrestee is teleported back to the prison and awaits the verdict. The jurors are then unmuted and are able to type and must deliberate for 1 minute. After the 1 minute has passed, the jurors are then muted again and asked to cast their verdict, they are given 30 seconds. After this, jurors are relieved from their duty and teleported back to the courthouse entrance. The verdict is then calculated. For a arrestee to be found not guilty, they must have a 2/3 or 3/5 vote. The verdict is then displayed to the public and the arrestee is either re-jailed for their remaining time or released depending on the outcome of the trial.

## Commands
| Command | Arguments | Explanation
| --- | --- | ---
| `/jail` | `PlayerID Time "Charges"` | This command is used by police to jail arrestees. The `PlayerID` is the ID of the player, the `Time` is the time in minutes, the `"Charges"` are the charges. The charges must be surrounded by quotes in order to capture all of the seperated words. |
| `/unjail` | `PlayerID` | This command is used by police to unjail an arrestee. The `PlayerID` is the ID of the player. |
| `/requesttrial` | None | This command is used by arrestees to request a court trial. There are no arguments for this command. |
| `/jurorverdict` | `yes` or `no` | This command is by jurors to send their verdict regarding the trial. `yes` is interpreted as guilty. `no` is interpreted as not guilty. |

## Configuration
The configuration file is located in `sh_config.lua`

| Configuration Key | Explanation
| --- | ---
| `JailConfig.jailFile` |  A string of the filepath for the json file in which the jailed players are stored.
| `JailConfig.stateName` | This is a string that is used in many factors of the system for the state. Ex. Superior Court of San Andreas. |
| `JailConfig.policePeds` | This is an array that the system checks against to see if a player is a police officer via checking the ped model. |
| `JailConfig.courtStartTime` | The system interprets this integer as the amount of minutes to give potential jurors to show up to the courthouse location. |
| `JailConfig.courtEntraceLocation` | This is an array that the system interprets as a vector for the courthouse front entrance. This is used to display the blip as well as the area in which the system will select jurors. |
| `JailConfig.defendantLocation` | This is an array that the system interprets as a vector for the position at which the defendant or arrestee will be during the court case. |
| `JailConfig.jurorLocations` | This is an array of vector arrays for each of the juror locations inside the courthouse.
| `JailConfig.prisonLocation` | This is an array that the system interprets as a vector for the prison location where arrestees are sent to jail.
| `JailConfig.prisonEntraceLocation` |  This an array that the system interprets as a vector for the entrance to the prison. This is where arrestees are sent after they are released.

## Credits
- [Gaming-Asylum](http://www.gaming-asylum.com/forums/index.php) - [Gaming-Asylum-Wiki](http://gaming-asylumwiki.com/wiki/Prison_Guide) - Gaming Asylum Servers have a similar jail and justice system on their Arma 3 servers. I drew inspiration from this server because their system is very effective and fun.

## Pictures
![Map Image of Courthouse](https://i.imgur.com/SHSOipy.jpg)
![Map Image of Court Area](https://i.imgur.com/41OIp84.jpg)
