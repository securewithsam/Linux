#### Auditing, system hardening, compliance testing
Lynis is a battle-tested security tool for systems running Linux, macOS, or Unix-based operating system. It performs an extensive health scan of your systems to support system hardening and compliance testing.

Security auditing
Compliance testing (e.g. PCI, HIPAA, SOx)
Penetration testing
Vulnerability detection
System hardening


```sh
sudo yum install lynis
```
```sh
sudo lynis audit system
```


#### Audit linux without installing Lynis
```sh
 git clone https://github.com/CISOfy/lynis
```
```sh
 cd lynis && ./lynis audit system
```
