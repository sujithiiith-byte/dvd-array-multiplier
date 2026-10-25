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
git clone --depth 1 https://github.com/iic-jku/IIC-OSIC-TOOLS.git ~/main_workspace/eda/IIC-OSIC-TOOLS
cd ~/main_workspace/eda/IIC-OSIC-TOOLS
DESIGNS=$HOME/main_workspace/dvd_assignment ./start_x.sh  #mount my work directory to /foss/designs

# Later sessions
docker start iic-osic-tools_xserver_uid_1000                  #To start docker container
docker exec -it iic-osic-tools_xserver_uid_1000 bash -l       #To open container's bash shell 
```

`PDK setup`
```bash
echo $PDK_ROOT $PDK
>> /foss/pdks ihp-sg13g2
sak-pdk sky130A
echo $PDK_ROOT $PDK
>> /foss/pdks sky130A
```


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
