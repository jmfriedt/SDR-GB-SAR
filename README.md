# SDR-GB-SAR

Opensource, openhardware implementation of a Software Defined Radio (SDR) Ground Based Synthetic-Aperture RADAR (GB-SAR [1])

The instrument is a Ground-Based Synthetic-Aperture-RADAR using a commercial, off the shelf WiFi dongle as pseudo-random
spectrum spread radiofrequency source, a Raspberry Pi 4 for data acquisition and antenna position control, and an Ettus
Research B210 SDR dual channel receiver for RADAR data acquisition.

The rail for moving the antenna set is a commercial, off the shelf device from <a href="https://www.iai-robot.co.jp/">IAI (Japan)</a>.

The radiofrequency signal source is an [Alfa Network AWUS036ACS](https://www.amazon.com/Network-AWUS036ACS-Wide-Coverage-Dual-Band-High-Sensitivity/dp/B0752CTSGD) WiFi USB dongle selected to cover the 5.8 GHz band and fitted with an RP-SMA antenna connector well adapted to be used, after converting [RP-SMA to SMA](https://www.digikey.fr/fr/products/detail/w%C3%BCrth-elektronik/64430203111000/10107023), to a [coupler](https://www.minicircuits.com/WebStore/dashboard.html?model=ZADC-10-63-S%2B) whose straight output feeds the horn antenna and coupled output feeds the reference channel of the [B210 SDR](https://www.ettus.com/all-products/ub210-kit/). The second input of the SDR is connected straight to the reception horn antenna.

<img src=CAD/gbsar_cad1.png>

<img src=CAD/gbsar_cad2.png>

[1] Hoonyol Lee and Jihyun Moon, Analysis of a Bistatic Ground-Based Synthetic Aperture Radar 
System and Indoor Experiments, MDPI Remote Sens. 2021, 13(1), 63; https://doi.org/10.3390/rs13010063 

## Connections

<img src="principle.png">

## Cost estimate

<table>
  <tr><td>Ainfo 4.9 to 7.05 GHz horn antenna (20 dB gain) LB-159-20-C-SF</td><td> 807 euros/p x2</td></tr>
  <tr><td>Ainfo mount bracket LB-159-10-C-MBL </td><td>202 euros/p</td></tr>
  <tr><td>IAI rail RCP5-BA6-WA-42P-48-2000-P3-S-CJT </td><td>1965+395 (software) euros</td></tr>
  <tr><td>B210 SDR </td><td>1854 euros (8 Feb. 2023)</td></tr>
  <tr><td>Raspberry Pi + misc. hardware (e.g. 3.3V to 24V converter) </td><td>200 euros</td></tr>
  <tr><td>MiniCircuits radiofrequency hardware (coupler ZADC-10-64, attenuators)</td><td> 72+~200</td></tr>
  <tr><td>WiFi dongle </td><td>~30 euros</td></tr>
  <tr><td>Total </td><td> 6734 euros</td></tr>
</table>

## Power consumption

<table>
  <tr><td>Motorized rail</td><td>500 mA/24V = 12 W</td></tr>
  <tr><td>Raspberry Pi 4</td><td> 300 mA/5V = 1.5 W</td></tr>
  <tr><td>B210 SDR</td><td> 210 mA/12V=2.5 W</td></tr>
  <tr><td>WiFi dongle (USB standard)</td><td> $<$500 mA/5V=2.5W</td></tr>
  <tr><td>Total</td><td> 18.5 W
</table>
