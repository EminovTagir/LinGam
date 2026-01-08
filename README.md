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

## Scoreboard

LinGam now includes a web-based scoreboard to track player progress!

### Access the Scoreboard

After deployment, access the scoreboard at:
```
http://your-server:5000
```

### Features

- **User Registration & Login**: Create an account to track your progress
- **Real-time Rankings**: See how you rank against other players
- **Task Progress**: View which tasks you've completed and which remain
- **Points System**: Each task awards points based on difficulty
- **Automatic Tracking**: Task completions are automatically recorded

### How to Use

1. **Register**: Visit the scoreboard URL and create an account with a username and password
2. **Complete Tasks**: Connect to tasks via SSH and solve them as usual
3. **Submit Completions**: Use the API to submit your task completions
4. **Track Progress**: View your ranking and completed tasks on the scoreboard

### Submitting Task Completions

When you complete a task, submit it to the scoreboard:

```bash
curl -X POST http://your-server:5000/api/complete_task \
  -H "Content-Type: application/json" \
  -d '{"username":"your_username", "task_name":"task_name", "flag":"your_flag"}'
```

Replace `your_username` with your scoreboard username and `task_name` with one of:
- `archives`
- `banme`
- `deletefile`
- `dothemathin30seconds`
- `knockknock`
- `largefile`
- `moldovavirus`
- `pincode`
- `projectfiles`

See [Scoreboard/README.md](Scoreboard/README.md) for more details.
