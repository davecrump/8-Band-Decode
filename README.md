# 8-Band-Decode
![8-Band-Decode banner](/8-Band Decode Built V2 small.jpg)
PIC Program for 8-band Decode Switch for Portsdown ATV transmitter

This program is for use on the Portsdown ATV Transmitter 8-band Decode PCB.  The PIC used is a 16F883, which provides the 12 logic inputs and 10 logic outputs required (with 2 spares).

8_Band_Decode.asm is the assembler source code for those who are curious or want to make changes.

8_Band_Decode.hex is the compiled file for programming into the 16F883 using the MPLab IDE/IPE or similar and a PICKit 3 PIC programmer.

Note that during programming the PCB must be powered, either from an external source or your PIC programmer, and the DIP switches must be in the off position as they share the programming pins.

Hardware details are on the BATC Wiki here https://wiki.batc.org.uk/8-Band_Decoder.

PCBs will be available from the BATC Shop.

Dave, G8GKQ
