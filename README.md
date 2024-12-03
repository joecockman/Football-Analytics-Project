# Football-Analytics-Project

The purpose of this project was to practice and to showcase my knowledge of SQL. I created a database named Sports Analytics that contained 5 tables 

potential things to find:
 - top goalscorer
 - top assists
 - top yellows
 - top reds
 - most wins
 - most defeats
 - average age of team - does age affect?
 - home advantage?


I began by creating my database named 'Sports Analytics'. I created the below 5 tables:

 - Players
 - Matches
 - Scores
 - Teams
 - Stats

Below is the code used to create the tables.

```
CREATE DATABASE SportsAnalytics;
USE SportsAnalytics;

CREATE TABLE Teams (
	team_id INT AUTO_INCREMENT PRIMARY KEY,
	team_name VARCHAR(100),
	city VARCHAR(100),
	coach_name VARCHAR(100)
);

CREATE TABLE Players (
	player_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    position VARCHAR(50),
    team_id INT,
    birth_date DATE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);
	
CREATE TABLE Matches (
	match_id INT AUTO_INCREMENT PRIMARY KEY,
    match_date DATE,
    home_team_id INT,
    away_team_id INT,
    venue VARCHAR(100),
    FOREIGN KEY (home_team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES Teams(team_id)
);

CREATE TABLE Scores (
	score_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT,
    team_id INT,
    goals_scored INT,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

CREATE TABLE Stats (
	stat_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT,
    match_id INT,
    minutes_played INT,
    goals INT,
    assists INT,
    yellow_cards INT,
    red_cards INT,
    FOREIGN KEY (player_id) REFERENCES Players(player_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);
```

Once I created the tables I generated the schema, seen below:

