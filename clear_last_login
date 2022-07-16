# How to clear last login user details and IP 

```sh
sudo lastlog --clear --user root
```
```sh
sudo lastlog -C -u root
```

## Verify
```sh
lastlog
lastlog --user root
```

## last and lastb use /var/log/wtmp and /var/log/btmp files to log information. You can use the following command to clear wtmp/btmp:
```sh
>/var/log/wtmp
```
```sh
>/var/log/btmp
```

## Clear all last login information by deleting the /var/log/lastlog

## make a backup of /var/log/lastlog [USE THIS ONLY IF YOU NEED BACKUP]
```sh
cp /var/log/lastlog /root
```

```sh
>/var/log/lastlog
```
```sh
cat > /var/log/lastlog
```

Press CTR+D to save the changes.
