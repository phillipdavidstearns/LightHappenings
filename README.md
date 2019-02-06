# Light Happenings

This repository holds the code base for the dynamic lighting installation/intervention produced for USM's launch of their new Haller E lighting system.

## Arduino

Code developed in Arduino to run on the ATtiny85. Reads incoming I2C messages and translates the bytes to PWM values. The MCU is connected to a MOSFET current sink driver, switching power to LED strips.

## Processing

Code developed in Processing to run allow for dynamic and programatic control of lighting over a network. A Server is run on Raspberry Pi that accepts messsages from a Client on any other system capable of running Processing. The Client sketch has basic GUI controls for setting the Animation mode and the Speed of playback.
