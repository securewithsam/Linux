#### How to monitor linux server using Cockpit PCP and Grafana
#### Red Hat Enterprise Linux 8.7 (Ootpa)

```sh

sudo yum install update -y
sudo dnf install cockpit
sudo systemctl enable --now cockpit.socket
sudo yum install cockpit-pcp -y
sudo yum install redis -y
```
```sh
systemctl start pmcd
systemctl start pmie
systemctl start pmlogger
```

```sh
https://Server IP:9090
```
```sh
Enable Overview> Metric Settings and enable collect metrics and export to network
```

#### Installing PCP Vector
```sh
yum install pcp-pmda-bcc
cd /var/lib/pcp/pmdas/bcc
./Install
```

#### Login to grafana server
```sh
sudo apt-get update && sudo apt-get upgrade -y
```
#### Installing the Performance Co-Pilot plugin manually
```sh 
sudo wget https://github.com/performancecopilot/grafana-pcp/releases/download/v5.0.0/performancecopilot-pcp-app-5.0.0.zip
sudo apt install unzip -y
sudo unzip -d /var/lib/grafana/plugins performancecopilot-pcp-app-5.0.0.zip
sudo systemctl restart grafana-server
```
```sh
On Grafana Dashboard >Add data source as PCP Redis 
http://hostname or IP:44322
save and test
```
