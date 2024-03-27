#### Enable Syslog 

```sh
nano /etc/rsyslog.conf
```
```sh
# Send logs to the InsightIDR Collector Remote Syslog Server IVP-INFSIEM-01
*.*   @10.10.10.80:1537
```
```sh
systemctl restart rsyslog
```

#### Sending audit logs to SYSLOG server using audisp , its a aprt of Audit Package

```sh
nano /etc/audisp/plugins.d/syslog.conf
```
```sh
active = yes
direction = out
path = builtin_syslog
type = builtin
args = LOG_INFO
format = string
```
```sh
systemctl restart rsyslog
```
