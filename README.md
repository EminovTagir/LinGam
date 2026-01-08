# LinGam (Linux Games)

LinGam - it's a battle format tasks on Linux.


## Requirements

You need to install on linux server next package:
>python3 (version > 3.9)
>
>golang
>
>docker / docker compose

## Deploy

Full build:
```bash=
cd /opt && 
mkdir shells &&
git clone https://github.com/bysmaks/LinGam && 
cd LinGam
chmod +x builder.sh &&
./builder.sh
```

## How to connect:

The service automatically creates users (username is the name of the service) with a password like name.
The users are already written in /etc/passwd and have special shells created for them to run.
One connection - one container startup, the container will be automatically destroyed when the session is finished.
You can connect to the server via:

```bash=
ssh archives@server
pass: archives

ssh banme@server
pass: banme

ssh deletefile@server
pass: deletefile

ssh dothemathin30seconds@server
pass: dothemathin30seconds

ssh knockknock@server
pass: knockknock

ssh largefile@server
pass: largefile

ssh moldovavirus@server
pass: moldovavirus

ssh pincode@server
pass: pincode

ssh projectfiles@server
pass projectfiles
```
