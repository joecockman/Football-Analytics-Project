# Football-Analytics-Project

![ELFL League Banner](Screenshots/ELFL-Banner.png)

The purpose of this project was to practice and to showcase my knowledge of SQL. I created a database named Sports Analytics and used Python Faker to populate the tables with fake data. the python code (team_name = faker.company() + " FC") generated team names using company names and adding FC to the end of them. The end result of this name generation was 20 teams who sounded like they were law firms, and thus the ELFL (English Law Firms League) was born.

# Creating the database

I began by creating my database named 'Sports Analytics 2'(Sports Analytics 1 was a failed practice attempt). I created 5 tables in this database, listed below:

 - Players
 - Matches
 - Scores
 - Teams
 - Stats

Below is the code used to create the tables.

```
CREATE DATABASE SportsAnalytics;
USE SportsAnalytics;
```

## Teams Table
```
CREATE TABLE Teams (
	team_id INT AUTO_INCREMENT PRIMARY KEY,
	team_name VARCHAR(100),
	city VARCHAR(100),
	coach_name VARCHAR(100)
);
```

## Players Table
```
CREATE TABLE Players (
	player_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    position VARCHAR(50),
    team_id INT,
    birth_date DATE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);
```

 ## Matches Table
 ```
CREATE TABLE Matches (
	match_id INT AUTO_INCREMENT PRIMARY KEY,
    match_date DATE,
    home_team_id INT,
    away_team_id INT,
    venue VARCHAR(100),
    FOREIGN KEY (home_team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES Teams(team_id)
);
```

## Scores Table
```
CREATE TABLE Scores (
	score_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT,
    team_id INT,
    goals_scored INT,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);
```

## Stats Table
```
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

## Database Schema

![Schema Preview](Sports-Analytics-Schema.png)

The links between my tables are outlined in the above schema. The teams table is the main table, linking to 3 of the other 4 tables, though it has no direct link to the stats table.

## Populating the database with data

Next up I had to populate the tables with data and for this I chose to use Python Faker, which easily generates mock data for databases based on your defined criteria. I used Jupyter notebook for all of my python code in this project. I am still learning Python and am by no means an expert yet, I therefore asked chatgpt to help me write the code for this portion of the project.

## Importing Faker and Setting up Standard Deviation Parameters
```
import random
from faker import Faker

faker = Faker()

# Parameters for normal distribution
mean_goals = 5      # Average goals
stddev_goals = 10     # Spread around the mean for goals

mean_assists = 5     # Average assists
stddev_assists = 10    # Spread around the mean for assists

mean_yellow_cards = 10
stddev_yellow_cards = 4

mean_red_cards = 0
stddev_red_cards = 2
```
In this first part of the code I import the faker library and then set up the distribution parameters for the stats from the stats table. This was something I initially had some trouble with.

When I first tried to set this up, I did not include a normal (Gaussian) distribution model. Instead I said that the maximum amount of goals, assists and cards a player could get across the season was 100 of each. I wanted the league to be exciting and high scoring, so I also set up that the maximum amount of home and away goals in any one game could be 10.

Without the Gaussian distribution model, I had it set to be completely random, but when I imported this data and queried it I found that a large majority of players had maxxed out all of their stats with 100 goals, assists and cards, and no one had less than 50. The large amount of games and the cap on player stats meant many players were maxxing out and subsequent goals, assists etc were just being divided out amongst the remaining players.

Once I found out you could include a distribution model, the results became much more realistic. I set the mean number for each of the stats and below it I set the stddev value.

Mean yellow cards of 10 with an SD of 4 therefore meant that the normal range of the bell curve would be 6-14. Outliers above or below this range were rarer but not impossible.

## Generating Teams Data
```
# Step 1: Generate Teams
teams = []
for team_id in range(1, 21):  # 20 teams
    teams.append({
        "team_id": team_id,
        "team_name": faker.company() + " FC",
        "city": faker.city(),
        "coach_name": faker.name(),
         "points": 0,  # Initialize points,
        "matches_played": 0  # Initialize matches played
    })
```
The above code generated data for the teams table.

## Generating Players Data
```
# Step 2: Generate Players
players = []
player_id = 1
for team in teams:
    for _ in range(11):  # Each team gets 11 players
        players.append({
            "player_id": player_id,
            "first_name": faker.first_name(),
            "last_name": faker.last_name(),
            "position": random.choice(["Goalkeeper", "Defender", "Midfielder", "Forward"]),
            "team_id": team["team_id"],  # Link player to their team
            "birth_date": faker.date_of_birth(minimum_age=18, maximum_age=65)
        })
        player_id += 1
```
The above code generated data for the Players table.

## Generating Matches Data
```
# Step 3: Generate Matches
matches = []
match_id = 1
for home_team in teams:
    for away_team in teams:
        if home_team["team_id"] != away_team["team_id"]:  # Ensure no matches against itself
            matches.append({
                "match_id": match_id,
                "home_team_id": home_team["team_id"],
                "away_team_id": away_team["team_id"],
                "match_date": faker.date_between(start_date='-1y', end_date='today'),
                "venue": home_team["city"]  # Assume matches happen in the home team's city
            })
            match_id += 1
```
The above code generated data for the Matches table.

## Generating Scores Data
```
# Step 4: Generate Scores and Update Points
scores = []
score_id = 1
for match in matches:
    home_goals = random.randint(0, 10)  # Max home goals = 10
    away_goals = random.randint(0, 10)  # Max away goals = 10

    # Record the scores
    scores.append({
        "score_id": score_id,
        "match_id": match["match_id"],
        "team_id": match["home_team_id"],
        "goals_scored": home_goals
    })
    score_id += 1
```
The above code generated data for the Scores table. As you can see I began this part by defining that the maximum amount of home and away goals in a single match could be 10 (meaning maximum score could be 10-10).

## Generating Stats Data
```
# Step 5: Generate Stats for Players with Normal Distribution for Goals and Assists
stats = []
stat_id = 1
for match in matches:
    for team_id in [match["home_team_id"], match["away_team_id"]]:  # Home and Away teams
        relevant_players = [p for p in players if p["team_id"] == team_id]  # Players from the team
        for player in random.sample(relevant_players, random.randint(7, 11)):  # 7-11 players per team
            goals = int(random.gauss(mean_goals, stddev_goals))  # Goals scored by player
            assists = int(random.gauss(mean_assists, stddev_assists))  # Assists by player
            yellow_cards = int(random.gauss(mean_yellow_cards, stddev_yellow_cards))  # yellow cards by player
            red_cards = int(random.gauss(mean_red_cards, stddev_red_cards))  # red cards by player

            # Clip values to stay within a reasonable range (0-50 goals and assists)
            goals = max(0, min(100, goals))  # Ensuring goals are between 0 and 100
            assists = max(0, min(100, assists))  # Ensuring assists are between 0 and 100
            yellow_cards = max(0, min(40, yellow_cards))  # Ensuring yellow cards are between 0 and 40
            red_cards = max(0, min(60, red_cards))  # Ensuring red cards are between 0 and 60

            stats.append({
                "stat_id": stat_id,
                "player_id": player["player_id"],
                "match_id": match["match_id"],
                "minutes_played": random.randint(0, 90),
                "goals": goals,
                "assists": assists,
                "yellow_cards": yellow_cards,
                "red_cards": red_cards
            })
            stat_id += 1
```
This part of the code was more complex and incorporated the mean and SD values we previously defined.

The code specifies that 'Goals' (as an example) will be an integer number, and it's value will be defined by the random.gauss command used in conjunction with the parameters, mean & stddev.

The clip values define our maximum value limit. Taking the goals example again, the mean was 5 and the SD was 10, meaning 0-15 would fall within the normal distribution. The clip value of 100 meant that it was technically possible to reach 100 goals, though this would require an Erling Haaland type finisher in our humble league.

## Inserting Values into MySQL Database
```
# Insert Teams into MySQL, including points
for team in teams:
    query = """ INSERT INTO Teams (team_id, team_name, city, coach_name, points, matches_played) VALUES (%s, %s, %s, %s, %s, %s) """
    cursor.execute(query, (team["team_id"], team["team_name"],  team["city"], team["coach_name"],  team["points"],  # Insert points team["matches_played"]  # Insert matches_played))

# Insert Players
for player in players:
    query = "INSERT INTO Players (player_id, first_name, last_name, position, team_id, birth_date) VALUES (%s, %s, %s, %s, %s, %s)"
    cursor.execute(query, (player["player_id"], player["first_name"], player["last_name"], player["position"], player["team_id"], player["birth_date"]))

# Insert Matches
for match in matches:
    query = "INSERT INTO Matches (match_id, home_team_id, away_team_id, match_date, venue) VALUES (%s, %s, %s, %s, %s)"
    cursor.execute(query, (match["match_id"], match["home_team_id"], match["away_team_id"], match["match_date"], match["venue"]))

# Insert Scores
for score in scores:
    query = "INSERT INTO Scores (score_id, match_id, team_id, goals_scored) VALUES (%s, %s, %s, %s)"
    cursor.execute(query, (score["score_id"], score["match_id"], score["team_id"], score["goals_scored"]))

# Insert Stats
for stat in stats:
    query = "INSERT INTO Stats (stat_id, player_id, match_id, minutes_played, goals, assists, yellow_cards, red_cards) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"
    cursor.execute(query, (stat["stat_id"], stat["player_id"], stat["match_id"], stat["minutes_played"], stat["goals"], stat["assists"], stat["yellow_cards"], stat["red_cards"]))

connection.commit()
print("Data inserted successfully!")
```

The final step was to take this data that we had generated and actually populate the MySQL database with it.

# Querying the Data
Now at last we had a full database, it was time to start querying the data. 20 teams. 38 games each. 760 total matches. Who knows what drama took place in the 2023/2024 ELFL season. Who would win the race for the golden boot, or the coveted playmaker trophy? Who would take the unfortunate title of being the most booked player? And ultimately, who would be living out every child's dream and lifting the ELFL trophy. Read on to find out.

## ELFL Top Scorers 2023/2024
```
# Top Scorers
select players.first_name, players.last_name, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age, players.position, 
teams.team_name, 
stats.goals
from players
join teams
on players.team_id = teams.team_id
join stats
on players.player_id = stats.player_id
order by stats.goals desc
limit 10;
```


## Top Scoring Teams

```
#Top Scoring Teams
select teams.team_name AS Team,  SUM(stats.goals) AS Total_Goals 
from teams
join players
on teams.team_id = players.team_id
join stats
on players.player_id = stats.player_id
group by team_name
order by SUM(stats.goals) desc;
```

## Goals by Age

```
# Goals by Age
SELECT first_name, last_name, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age, stats.goals
FROM players
join stats
on players.player_id = stats.player_id
order by goals desc;
```

