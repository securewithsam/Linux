### Use case : In a CLI only linux with no GUI how to test the localhost application on a remote machine 


### Open cmd
```bash
ssh -N -L 18789:127.0.0.1:18789 infra-admin@20.151.xxx.xx
```

### Enter your password when prompted. Leave that terminal open.
### Then open your browser on that same Ubuntu machine and go to:

```bash
http://localhost:18789
```
