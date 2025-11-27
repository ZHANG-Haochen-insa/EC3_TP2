## ============================================================================
## XDC Constraints for Digicode Q2 (Modification de Code)
## Nexys A7-100T FPGA Board
## ============================================================================

## ============================================================================
## Clock Signal - 100MHz System Clock
## ============================================================================
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLK100MHZ }];

## ============================================================================
## Reset Button - BTNC (Center Button)
## ============================================================================
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { CPU_RESETN }];

## ============================================================================
## Push Buttons for Password Input
## ============================================================================
## BTND - Down Button (Code: 0001)
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { BTND }];

## BTNR - Right Button (Code: 0010)
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { BTNR }];

## BTNU - Up Button (Code: 0100)
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { BTNU }];

## BTNL - Left Button (Code: 1000)
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { BTNL }];

## ============================================================================
## Switches
## ============================================================================
## SW0 - Door status switch (0=closed, 1=open)
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { SW0 }];

## SW1 - Code modification mode switch (1=enter modification mode)
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { SW1 }];

## ============================================================================
## LEDs
## ============================================================================
## LED0 - Address bit 0 (shows which digit is being verified)
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { LED0 }];

## LED1 - Address bit 1 (shows which digit is being verified)
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { LED1 }];

## LED2 - Door lock status (1=open, 0=closed)
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { LED2 }];

## LED3 - Code modification mode indicator (1=in modification mode)
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { LED3 }];

## ============================================================================
## Configuration Options
## ============================================================================
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## ============================================================================
## Bitstream Options
## ============================================================================
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
