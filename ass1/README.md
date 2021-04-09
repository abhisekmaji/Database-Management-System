# col362-ass1
#### SQL queries
Analyze IPL data from 2008-2016.

Analysis done in postgres. The database includes fifteen tables:
- Table player
- Table match
- Table player_match
- Table ball_by_ball
- Table batsman_scored
- Table wicket_taken
- Table season
- Table win_by
- Table team
- Table role
- Table country
- Table outcome
- Table out_type
- Table bowling_style
- Table batting_style

Opening the database `ass1`:
```
sudo -u postgres psql ass1
```
Adding the **tables** to the database:
```
\i /path_to/db_build.sql
```
Running the sql queries:
```
\i /path_to/query.sql
```
Calculating the time for sql queries:
```
\timing on
\i /path_to/query.sql
\timing off
```

The queries are:

1. Return the bowlers that took 5 or more wickets in a single match. sort in descending order of
num_wickets. Break ties by ascending order by player_name and then team_name. Columns:
match_id, player_name, team_name, num_wickets.
2. Top 3 (all of them if count is less than 3) players who won most Man-of-the-matches being
in a losing team. Sort in descending order of num_matches. Break ties with ascending
(lexicographical) order of player names. Columns: Player_name, num_matches.
3. Return the player who took most number of catches (as a fielder) in the year 2012. Break ties
by ascending (lexicographical) order of player names. Columns: player_name.
4. Return number of matches played by the purple cap player in that respective season. Sort in
ascending order of season year. Columns: season_year, player_name, num_matches.
5. Return the players who scored more than 50 runs in the matches their team lost. Sort in
ascending (lexicographical) of player names. Columns: player_name.
6. Return top 5 teams with most left handed foreign batsmen in each season. Sort in ascending
order of season year. Break ties of number of such batsmen by ascending (lexicographical)
order of team names in a season. Columns: season_year, team_name, rank.
7. Return the teams in the order of maximum match wins in the season 2009. Break ties by
ascending (lexicographical) order of team names. Columns: team_name
Note: consider the match_winner column of table match to decide the winner and take care
of null values.
8. Return the top run scorer of each team in the year, 2010. Sort in the ascending order of
team names. Break ties between players in the ascending order of player names. Columns:
team_name, player_name, runs.
9. Return top 3 teams with maximum number of sixes (runs_scored is 6 in batsman_scored) in
a single innings in the season 2008. Break ties by ascending order of team names. Columns:
team_name, opponent_team_name, number of sixes
10. Return players with maximum batting average who took more wickets than an average bowler
in each bowling category in all the seasons (Consider all matches of all seasons). Sort in
ascending order of bowling_skill. Break ties in ascending order of player_name. Columns:
bowling_category, player_name, batting_average.
11. Return all the left handed batsmen who scored 150 or more runs and took 5 or more wickets
and played 10 or more matches in a season. Sort in descending order of number of wickets, descending order of runs in the season. Break ties by ascending order of player names. Columns:season_year, player_name, num_wickets, runs.
12. Find the season, match id,player name,team name and number of wickets where the highest
number of wickets taken by a player in a match. Sort in descending order of number of
wickets. Break ties by ascending order of player name, ascending order of match_id. Columns:
match_id, player_name, team_name, num_wickets, season_year
13. Return all the players who played in all the seasons. Sort in order of ascending order of player
names. Columns: player_name.
14. Return top 3 teams for each season based on number of batsmen with a score of 50 or more in
a match they won. Sort in ascending order of season year and rank the teams in descending
order of number of batsmen with a score of 50+. Break ties by ascending order of team names.
Columns: season_year, match_id, team_name
15. Return Players with second highest runs, second highest wickets along with the number of runs
and wickets for each season. Sort in ascending order of season year. Break ties by ascending
order of player names for both batsmen and bowlers while ranking. Columns: season_year,
top_batsman, max_runs, top_bowler, max_wickets
16. Find all teams against which ’Royal Challengers Bangalore’ lost a match in 2008. Sort in
descending order of number of matches won against ’Royal Challengers Bangalore’ in 2008.
Break ties by ascending order of team name. Columns: team_name.
17. For each team, return the player who has been awarded man of the match maximum number
of times. Sort in order of ascending order of team names. Break ties by ascending order of
player name while ranking. Columns: team_name, player_name, count.
18. Return top 5 players who played in 3 or more teams and have conceded more than 20 runs in an
over for the most number of times. Break ties by ascending order of player names. Columns:
player_name.
19. Return average runs of each team in season 2010, rounded off to 2 decimals. (Ignore the
extras). Sort in ascending order of team name. Columns: team_name, avg_runs.
20. Return top 10 players who got out in the first over (of the match) for most number of times.
Break ties by ascending order of player names. Columns: player_names.
21. Return top 3 matches where team wins by chasing with least number of boundaries. Sort in
ascending order of number of boundaries. Break ties by ascending order of match_winner team
name, team_1 name, team_2 name. Columns: Match_id, team_1_name, team_2_name,
match_winner_name, number_of_boundaries.
22. . Return the countries of top 3 players with lowest average runs conceded per number of wickets
taken over all matches. Break ties by ascending order of player name. Discard players with 0
total wickets. Columns: country_name.
