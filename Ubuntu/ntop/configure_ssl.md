#### Use a Self-Signed Certificate (internal networks)
```sh
sudo mkdir -p /etc/ntopng/certs
cd /etc/ntopng/certs

sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout ntop.key \
  -out ntop.crt
```
#### Configure ntopng to use SSL

```sh
sudo nano /etc/ntopng/ntopng.conf
```
Add:
```sh
--https-port="443"
--certificate="/etc/ntopng/certs/ntop.crt"
--key="/etc/ntopng/certs/ntop.key"

```
```sh
sudo systemctl restart ntopng

```
