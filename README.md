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

Worked example (hand calculation and waveform): A = 7, B = 9, from Vedant's roll number 2023112012
(last digit 2, A = 2 + 5 = 7, so B = 9); 7 x 9 = 63.

## Part B: Logic synthesis

```bash
yosys -c synth/synth.tcl     # -> synth/mult_array_netlist.v, synth/mult_array_stat.rpt

# Gate-level simulation of the netlist with the SKY130 cell models
CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls \
  tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
vvp gls                      # PASS: 256 vectors checked, 0 errors
```

## Part C: Static timing analysis

```bash
sta sta/sta.tcl              # T = 10 ns (default) -> worst slack max 7.40
                             #   Tmin = 10 - 7.40 = 2.60 ns, Fmax = 1000/2.60 = 384.6 MHz
T=2.60 sta sta/sta.tcl       # T = Tmin -> worst slack max 0.00 (report: sta/mult_array_timing.rpt)
```

## Part D: Physical design (LibreLane)

```bash
cd pnr
librelane --manual-pdk --pdk sky130A --run-tag run<N>_<period>ns config.json
# after the passing run:
cp runs/run8_7p0ns/final/metrics.json metrics.json
cp runs/run8_7p0ns/final/gds/mult_array.gds mult_array.gds
klayout mult_array.gds       # layout screenshots
```

`--manual-pdk` uses the SKY130 PDK installed in the container. Start value:
CLOCK_PERIOD = 1.2 x 2.60 = 3.12 -> 3.5 ns, then +0.5 ns per failed run.

| Run | CLOCK_PERIOD (ns) | Setup slack, all corners (ns) | DRC | LVS | Result |
|-----|-------------------|-------------------------------|-----|-----|--------|
| 1 | 3.5 | -2.154 | 0 | 0 | failed: setup (ss corner) |
| 2 | 4.0 | -1.654 | 0 | 0 | failed: setup (ss corner) |
| 3 | 4.5 | -1.154 | 0 | 0 | failed: setup (ss corner) |
| 4 | 5.0 | -0.654 | 0 | 0 | failed: setup (ss corner) |
| 5 | 5.5 | -0.155 | 0 | 0 | failed: setup (ss corner) |
| 6 | 6.0 | -0.107 | 0 | 0 | failed: setup (ss corner) |
| 7 | 6.5 | -0.136 | 0 | 0 | failed: setup (ss corner) |
| 8 | 7.0 | +0.364 | 0 | 0 | passed |

## Results summary

| Part | Result |
|------|--------|
| A | RTL simulation: PASS, 256 vectors, 0 errors; error test (`sum = a^b`): FAIL, 95 errors |
| B | 73 cells, 805.773 um^2, 16 flip-flops (49.69 % of the area); netlist simulation: PASS |
| C | WNS 7.40 ns at T = 10 ns, Tmin 2.60 ns, Fmax 384.6 MHz; critical path `b_reg[0]` -> `p[6]` |
| D | CLOCK_PERIOD 7.0 ns (8 runs), 1895 cells, setup slack +0.364 ns, post-route Fmax 150.7 MHz, DRC 0, LVS 0 |

## Repository structure

```
README.md
rtl/      full_adder.v, mult_array.v           RTL design
tb/       tb_mult.v                            exhaustive self-checking testbench
synth/    synth.tcl                            Yosys script
          mult_array_netlist.v, _stat.rpt      generated netlist and cell/area report
sta/      sta.tcl                              OpenSTA script
          mult_array_timing.rpt                generated critical path report (T = 2.60 ns)
pnr/      config.json                          LibreLane configuration
          metrics.json, mult_array.gds         copied from the final run (runs/ not committed)
report/   report.pdf                           results, screenshots, answers to the questions
```

## Report

`report/report.pdf`: results tables, screenshots and answers to the questions for Parts A–D.
