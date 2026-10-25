# 4-bit Array Multiplier from RTL to GDSII with Open-Source Tools

Course: Digital VLSI Design

## Team

| Name | Roll number |
|------|-------------|
| Vedant Pahariya | 2023112012 |
| N Sujith Kumar | 2025802004 |

## Environment Setup

All tools run inside the IIC-OSIC-TOOLS Docker image on Ubuntu 22.04 (WSL2).

```bash
# On the host (one time)
docker pull hpretl/iic-osic-tools:latest

# Start a tools shell (repo mounted at /foss/designs, SKY130 selected, GUI apps via WSLg)
docker run --rm -it --name eda_shell --user 1000:1000 -e PDK=sky130A \
  -e DISPLAY=$DISPLAY -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix -v /mnt/wslg:/mnt/wslg \
  -v $HOME/main_workspace/dvd_assignment:/foss/designs -w /foss/designs \
  hpretl/iic-osic-tools:latest -s bash

# Inside the container: tool check
iverilog -V | head -1
yosys -V
sta -version
echo $PDK_ROOT $PDK      # -> /foss/pdks sky130A
```

The image's default PDK is `ihp-sg13g2`; `-e PDK=sky130A` selects SKY130
(inside a running shell, `sak-pdk sky130A` does the same).


## Part A: RTL design and verification

Inside the container, from `/foss/designs`:

```bash
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim                  # PASS: 256 vectors checked, 0 errors
gtkwave mult.vcd         # waveform (also viewed in Vivado)
```

Error test: in `rtl/full_adder.v` changed `assign sum = a^b^cin;` to `assign sum = a^b;`, then:

```bash
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim                  # FAIL: 256 vectors checked, 95 errors
```

Undid the change and re-ran: PASS.

## Part B: Logic synthesis

```bash
yosys -c synth/synth.tcl    

# Gate-level simulation of the netlist with the SKY130 cell models
CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls \
  tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
vvp gls                      # PASS: 256 vectors checked, 0 errors
```
