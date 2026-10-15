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

