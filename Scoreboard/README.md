# LinGam Scoreboard

A web-based scoreboard system for tracking LinGam CTF challenge completions.

## Features

- **User Authentication**: Register and login to track your progress
- **Real-time Scoreboard**: See rankings based on completed tasks and points
- **Task Tracking**: Automatically tracks when you complete tasks
- **RESTful API**: Submit task completions via API

## Setup

The scoreboard is automatically deployed when you run `builder.sh` from the main directory.

## Accessing the Scoreboard

Once deployed, access the web interface at:
```
http://your-server:5000
```

## User Registration

1. Navigate to the scoreboard URL
2. Click "Register"
3. Create a username and password
4. Login to view the scoreboard

## API Usage

Tasks can automatically submit completions using the API:

```bash
curl -X POST http://localhost:5000/api/complete_task \
  -H "Content-Type: application/json" \
  -d '{"username":"your_username", "task_name":"task_name", "flag":"your_flag"}'
```

### API Parameters

- `username` (required): The username of the player
- `task_name` (required): The internal name of the task (e.g., "archives", "banme", etc.)
- `flag` (optional): The flag/answer submitted

### Available Tasks

- archives
- banme
- deletefile
- dothemathin30seconds
- knockknock
- largefile
- moldovavirus
- pincode
- projectfiles

## Database

The scoreboard uses SQLite and stores data in `/opt/scoreboard_data/scoreboard.db` on the host system.

## Manual Task Completion

If you want to manually mark a task as complete:

```bash
curl -X POST http://localhost:5000/api/complete_task \
  -H "Content-Type: application/json" \
  -d '{"username":"myusername", "task_name":"archives", "flag":"flag_is_super_archive"}'
```

## Architecture

- **Backend**: Flask with SQLAlchemy ORM
- **Database**: SQLite
- **Frontend**: HTML/CSS templates
- **Container**: Docker container running on host network

## Development

To run locally:

```bash
cd Scoreboard
pip install -r requirements.txt
python app.py
```

The app will be available at `http://localhost:5000`.
