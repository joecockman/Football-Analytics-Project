CREATE DATABASE SportsAnalytics2;
USE SportsAnalytics2;

CREATE TABLE Teams (
	team_id INT AUTO_INCREMENT PRIMARY KEY,
	team_name VARCHAR(100),
	city VARCHAR(100),
	coach_name VARCHAR(100)
);

ALTER TABLE Teams
ADD COLUMN points INT DEFAULT 0,
ADD COLUMN matches_played INT DEFAULT 0;


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

select * from teams;


#Home Wins
SELECT 
    count(*) AS home_wins
FROM Matches
JOIN Scores AS home_scores 
    ON matches.match_id = home_scores.match_id AND matches.home_team_id = home_scores.team_id
JOIN Scores AS away_scores 
    ON matches.match_id = away_scores.match_id AND matches.away_team_id = away_scores.team_id
WHERE home_scores.goals_scored < away_scores.goals_scored;

#Away Wins
select count(*) as away_wins
from matches
join scores as away_scores
on matches.match_id = away_scores.match_id AND matches.away_team_id = away_scores.team_id
join scores as home_scores
on matches.match_id = home_scores.match_id AND matches.home_team_id= home_scores.team_id
where away_scores.goals_scored = home_scores.goals_scored;

ALTER TABLE stats
ADD COLUMN total_goal_involvements INT GENERATED ALWAYS AS (goals + assists) STORED;

# Top Goal Involvements
select players.first_name, players.last_name, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age, players.position, 
teams.team_name, 
stats.goals, stats.assists, stats.total_goal_involvements
from players
join teams
on players.team_id = teams.team_id
join stats
on players.player_id = stats.player_id
order by total_goal_involvements desc
limit 10;

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

# Top Assists
select players.first_name, players.last_name, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age, players.position, 
teams.team_name, 
stats.assists
from players
join teams
on players.team_id = teams.team_id
join stats
on players.player_id = stats.player_id
order by stats.assists desc
limit 10;

#Top Scoring Teams
select teams.team_name, sum(goals_scored) 
from scores
join teams
on teams.team_id = scores.team_id
group by teams.team_name
order by sum(goals_scored) desc;

# League Table
select teams.team_name; 

# Yellow Cards
select players.first_name, players.last_name, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age, players.position, teams.team_name, stats.yellow_cards
from players
join stats
on players.player_id = stats.player_id
join teams
on players.team_id = teams.team_id
order by stats.yellow_cards desc
limit 10;

# Red Cards
select players.first_name, players.last_name, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age, teams.team_name, stats.red_cards
from players
join stats
on players.player_id = stats.player_id
join teams
on players.team_id = teams.team_id
order by stats.red_cards desc
limit 10;

# Total Cards
select players.first_name, players.last_name, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age, teams.team_name, stats.yellow_cards, stats.red_cards, stats.total_cards
from players
join stats
on players.player_id = stats.player_id
join teams
on players.team_id = teams.team_id
order by stats.total_cards desc
limit 10;

ALTER TABLE stats
ADD COLUMN total_cards INT GENERATED ALWAYS AS (yellow_cards + red_cards) STORED;

select matches.match_id, teams.team_id, teams.team_name
from matches
join teams
on teams.team_id = matches.away_team_id OR teams.team_id = matches.home_team_id
where teams.team_id = 1;

select matches.match_id, matches.match_date, matches.home_team_id, matches.away_team_id, matches.venue,
scores.score_id, scores.team_id, scores.goals_scored,
teams.team_name
from matches
join scores
on matches.match_id = scores.match_id
join teams 
on scores.team_id = teams.team_id
order by matches.match_id;

select matches.match_id, matches.match_date, matches.home_team_id, matches.away_team_id, matches.venue,
home_scores.score_id, home_scores.team_id, home_scores.goals_scored,
teams.team_name
from matches
join scores as home_scores
on matches.match_id = home_scores.match_id AND matches.home_team_id = home_scores.team_id
join scores as away_scores
on matches.match_id = away_scores.match_id AND matches.away_team_id = away_scores.team_id
join teams 
on home_scores.team_id = teams.team_id
order by matches.match_id;

(case 
	when home_scores.goals_scored > away_scores.goals_scored Then "Home Win"
    when home_scores.goals_scored < away_scores.goals_scored then "Away Win"
    else "Draw"
end)


#Home Wins
SELECT 
    count(*) AS home_wins
FROM Matches
JOIN Scores AS home_scores 
    ON matches.match_id = home_scores.match_id AND matches.home_team_id = home_scores.team_id;
    
    #Home Wins
SELECT count(*)
FROM Matches
JOIN Scores AS home_scores 
    ON matches.match_id = home_scores.match_id AND matches.home_team_id = home_scores.team_id
JOIN Scores AS away_scores 
    ON matches.match_id = away_scores.match_id AND matches.away_team_id = away_scores.team_id = 
    (case 
	when home_scores.goals_scored > away_scores.goals_scored Then "Home Win"
    when home_scores.goals_scored < away_scores.goals_scored then "Away Win"
    else "Draw"
end);

SELECT
    team_id,
    SUM(CASE WHEN result = 'Win' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN result = 'Draw' THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN result = 'Loss' THEN 1 ELSE 0 END) AS losses
FROM (
    -- Results for home teams
    SELECT 
        m.home_team_id AS team_id,
        CASE 
            WHEN home.goals_scored > away.goals_scored THEN 'Win'
            WHEN home.goals_scored < away.goals_scored THEN 'Loss'
            ELSE 'Draw'
        END AS result
    FROM Matches m
    JOIN Scores home ON m.match_id = home.match_id AND m.home_team_id = home.team_id
    JOIN Scores away ON m.match_id = away.match_id AND m.away_team_id = away.team_id
    
    UNION ALL

    -- Results for away teams
    SELECT 
        m.away_team_id AS team_id,
        CASE 
            WHEN away.goals_scored > home.goals_scored THEN 'Win'
            WHEN away.goals_scored < home.goals_scored THEN 'Loss'
            ELSE 'Draw'
        END AS result
    FROM Matches m
    JOIN Scores home ON m.match_id = home.match_id AND m.home_team_id = home.team_id
    JOIN Scores away ON m.match_id = away.match_id AND m.away_team_id = away.team_id
) AS combined
GROUP BY team_id
ORDER BY wins DESC, draws DESC, losses ASC;

select 
* from teams
order by points desc;

select * from matches
order by match_date;

select * from teams
join matches
on teams.team_id = matches.home_team_id
where home_team_id = 19 AND away_team_id = 3;

select * from matches
join scores
on matches.match_id = scores.match_id
where matches.match_id = 342;

select * from teams;

select matches.match_id, avg(stats.yellow_cards)
from matches
join stats
on matches.match_id = stats.match_id
group by matches.match_id
having matches.match_id = 379;

select * from stats
where match_id = 379;

select match_id, sum(goals_scored) from scores
group by match_id
order by sum(goals_scored) desc;

select * from teams;



select * from teams
join matches
on teams.team_id = matches.home_team_id
where home_team_id = 18 AND away_team_id = 20;

select * from matches
order by match_date;



