#!/usr/bin/env python3
from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import secrets
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', secrets.token_hex(32))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///scoreboard.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Database Models
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    completions = db.relationship('TaskCompletion', backref='user', lazy=True)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    display_name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    points = db.Column(db.Integer, default=100)
    completions = db.relationship('TaskCompletion', backref='task', lazy=True)

class TaskCompletion(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    task_id = db.Column(db.Integer, db.ForeignKey('task.id'), nullable=False)
    completed_at = db.Column(db.DateTime, default=datetime.utcnow)
    flag_submitted = db.Column(db.String(200))

    __table_args__ = (db.UniqueConstraint('user_id', 'task_id', name='_user_task_uc'),)

# Initialize database
with app.app_context():
    db.create_all()
    
    # Add default tasks if they don't exist
    tasks_data = [
        {'name': 'archives', 'display_name': 'Archives', 'description': 'Extract flag pieces from nested archives', 'points': 100},
        {'name': 'banme', 'display_name': 'BanMe', 'description': 'Find the external IP with most BAN attempts', 'points': 150},
        {'name': 'deletefile', 'display_name': 'DeleteFile', 'description': 'Delete a file that prevents the program from running', 'points': 50},
        {'name': 'dothemathin30seconds', 'display_name': 'DoTheMathIn30Seconds', 'description': 'Calculate the sum of PIDs from forked processes', 'points': 150},
        {'name': 'knockknock', 'display_name': 'KnockKnock', 'description': 'Perform port knocking to open the web server', 'points': 120},
        {'name': 'largefile', 'display_name': 'LargeFile', 'description': 'Find a password in a large file with specific characteristics', 'points': 130},
        {'name': 'moldovavirus', 'display_name': 'MoldovaVirus', 'description': 'Collect password pieces scattered across many files', 'points': 140},
        {'name': 'pincode', 'display_name': 'PinCode', 'description': 'Brute force a 5-digit PIN code', 'points': 100},
        {'name': 'projectfiles', 'display_name': 'ProjectFiles', 'description': 'Calculate the sum of filename lengths', 'points': 110},
    ]
    
    for task_data in tasks_data:
        if not Task.query.filter_by(name=task_data['name']).first():
            task = Task(**task_data)
            db.session.add(task)
    
    db.session.commit()

# Routes
@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('scoreboard'))
    return redirect(url_for('login'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        if not username or not password:
            return render_template('register.html', error='Username and password are required')
        
        if User.query.filter_by(username=username).first():
            return render_template('register.html', error='Username already exists')
        
        user = User(username=username)
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        
        session['user_id'] = user.id
        session['username'] = user.username
        return redirect(url_for('scoreboard'))
    
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = User.query.filter_by(username=username).first()
        
        if user and user.check_password(password):
            session['user_id'] = user.id
            session['username'] = user.username
            return redirect(url_for('scoreboard'))
        
        return render_template('login.html', error='Invalid username or password')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/scoreboard')
def scoreboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    # Get all users with their scores
    users_scores = db.session.query(
        User.username,
        db.func.count(TaskCompletion.id).label('tasks_completed'),
        db.func.sum(Task.points).label('total_points')
    ).outerjoin(TaskCompletion, User.id == TaskCompletion.user_id)\
     .outerjoin(Task, TaskCompletion.task_id == Task.id)\
     .group_by(User.id)\
     .order_by(db.func.sum(Task.points).desc().nullslast(), db.func.count(TaskCompletion.id).desc())\
     .all()
    
    # Get all tasks
    tasks = Task.query.all()
    
    # Get current user's completions
    user_completions = TaskCompletion.query.filter_by(user_id=session['user_id']).all()
    completed_task_ids = {c.task_id for c in user_completions}
    
    return render_template('scoreboard.html', 
                         users_scores=users_scores,
                         tasks=tasks,
                         completed_task_ids=completed_task_ids,
                         current_username=session['username'])

# API endpoint for task completion
@app.route('/api/complete_task', methods=['POST'])
def complete_task():
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    username = data.get('username')
    task_name = data.get('task_name')
    flag = data.get('flag', '')
    
    if not username or not task_name:
        return jsonify({'error': 'Username and task_name are required'}), 400
    
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    task = Task.query.filter_by(name=task_name).first()
    if not task:
        return jsonify({'error': 'Task not found'}), 404
    
    # Check if already completed
    existing = TaskCompletion.query.filter_by(user_id=user.id, task_id=task.id).first()
    if existing:
        return jsonify({'message': 'Task already completed', 'points': 0}), 200
    
    # Add completion
    completion = TaskCompletion(user_id=user.id, task_id=task.id, flag_submitted=flag)
    db.session.add(completion)
    db.session.commit()
    
    return jsonify({
        'message': 'Task completed successfully!',
        'points': task.points,
        'task': task.display_name
    }), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
