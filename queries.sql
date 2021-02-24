--1--
SELECT match_id,player_name,team_name,num_wickets
FROM 
    (SELECT match_id, bowler, team_bowling, COUNT(player_out) AS num_wickets
    FROM ball_by_ball NATURAL JOIN wicket_taken
    WHERE kind_out NOT IN (3,5,9) AND innings_no = (1,2)
    GROUP BY match_id, bowler, team_bowling
    HAVING COUNT(player_out) >= 5
    ) AS a, player, team
WHERE player.player_id=a.bowler AND team.team_id = a.team_bowling
ORDER BY a.num_wickets DESC, player_name, team_name;

--2--
SELECT player_name, a.num_matches
FROM 
    (SELECT player_match.player_id, COUNT(player_match.match_id) as num_matches
    FROM player_match INNER JOIN match
        ON  player_match.match_id = match.match_id AND
            player_match.man_of_the_match = match.player_id
    WHERE NOT player_match.team_id = match.match_winner
    GROUP BY player_match.player_id ) as a, player
WHERE player.player_id = a.player_id
ORDER BY a.num_matches DESC, player_name;
LIMIT 3;

--3--
SELECT player_name
FROM 
    (SELECT fielders, COUNT(player_out) as num_catches
    FROM match NATURAL JOIN wicket_taken
    WHERE season_id =(SELECT season_id
                    FROM season
                    WHERE season_year=2012) 
        AND innings_no in (1,2)
        AND kind_out in (SELECT out_id
                        FROM out_type
                        WHERE out_name = 'catch')  
    GROUP BY fielders) as f, player
WHERE player.player_id = f.fielders
ORDER BY f.num_catches DESC, player_name
LIMIT 1;

--4--
SELECT g.season_year, player.player_name , g.num_matches
FROM
    (SELECT f.season_year, pm.player_id, COUNT(f.match_id) as num_matches
    FROM
        (SELECT match_id, season_id, season_year, purple_cap 
        FROM match NATURAL JOIN season) as f NATURAL JOIN player_match as pm
    WHERE pm.player_id = f.purple_cap
    GROUP BY f.season_year, pm.player_id) as g NATURAL JOIN player
ORDER BY g.season_year;

--5--
SELECT player_name
FROM 
    (SELECT striker
    FROM 
        (SELECT match_id, striker, team_batting , SUM(runs_scored)
        FROM ball_by_ball NATURAL JOIN batsman_scored
        WHERE innings_no in (1,2)
        GROUP BY match_id , striker , team_batting
        HAVING SUM(runs_scored) > 50) NATURAL JOIN match
    WHERE NOT team_batting = match_winner) NATURAL JOIN player
ORDER BY player_name;

--6--
SELECT h.season_year , h.team_name , h.rank
FROM
    (SELECT team_name, g.season_year,
            row_number() OVER (PARTITION BY season_year 
                    ORDER BY g.count_left_foreign_players DESC, g.team_name) as rank
    FROM 
        (SELECT team_id , season_year, COUNT(player_id) as count_left_foreign_players
        FROM 
            (SELECT player_id, season_year, team_id
            FROM 
                (SELECT match_id, season_year
                FROM match NATURAL JOIN season
                ) as f 
                    NATURAL JOIN player_match
            GROUP BY player_id, season_year, team_id) NATURAL JOIN player
        WHERE batting_hand IN (SELECT batting_id
                                FROM batting_style
                                WHERE batting_skill = 'left')
            AND country_id NOT IN (SELECT country_id
                                    FROM country
                                    WHERE country_name = 'india')
        GROUP BY team_id, season_year
        )as g NATURAL JOIN team
    ) as h
WHERE h.rank <= 5
ORDER BY season_year, h.rank DESC;

--7--
SELECT team_name 
FROM 
    (SELECT match_winner, season_id, COUNT(match_id) AS wins 
    FROM match NATURAL JOIN season
    WHERE outcome_id IS NOT NULL
        AND season_id IN (SELECT season_id
                            FROM season
                            WHERE season_year = 2009 )
    GROUP BY match_winner,season_id), team
WHERE team_id = match_winner
ORDER BY wins DESC, team_name;

--8--
SELECT team_name, player_name, runs
FROM
    (SELECT team_id, player_id,team_name, player_name, max(runs_player) as runs 
    FROM 
        (SELECT team_id, player_id, team_name, player_name, SUM(runs_match) as runs_player
        FROM 
            (
                SELECT team_batting, striker, match_id, SUM(runs_scored) as runs_match
                FROM ball_by_ball NATURAL JOIN batsman_scored
                WHERE innings_no in (1,2)
                GROUP BY team_batting, striker, match_id
            ), team,player
        WHERE team_id = team_batting AND player_id = striker
            AND match_id in (
                        SELECT match_id, season_id
                        FROM match NATURAL JOIN season
                        WHERE season_year = 2010
                    )
        GROUP BY team_id, player_id, team_name, player_name)
    GROUP BY team_id, player_id,team_name, player_name)
ORDER BY team_name, player_name;

--9--
SELECT a.team_name, b.team_name as opponent_team_name, number_of_sixes as [number of sixes]
FROM (SELECT team_batting, team_bowling, number_of_sixes
    FROM
        (
            SELECT team_batting, team_bowling, match_id, COUNT(players) as number_of_sixes
            FROM ball_by_ball NATURAL JOIN batsman_scored
            WHERE innings_no BETWEEN 1 AND 2 AND runs_scored = 6
            GROUP BY team_batting, team_bowling, match_id
        ) as f,
        (
            SELECT match_id, season_id
            FROM match NATURAL JOIN season
            WHERE season_year = 2008
        ) as g
    WHERE f.match_id = g.match_id) as h, team as a, team as b
WHERE h.team_batting = a.team.team_id AND g.team_bowling = b.team_id
ORDER BY number_of_sixes DESC, team_name
LIMIT 3;

--10--


--11--
SELECT m.season_year, player.player_name, m.num_wickets, m.runs
FROM(
    SELECT g.season_id, g.striker as player_id, g.season_year,
    SUM(runs_match) as runs, sum(wickets_match) as num_wickets, COUNT(g.match_id) 
    FROM
        (SELECT match_id, season_id, season_year, striker, runs_match
        FROM
            (
                SELECT match_id, striker, SUM(runs_scored) as runs_match
                FROM ball_by_ball NATURAL JOIN batsman_scored
                WHERE innings_no IN (1,2)
                GROUP BY match_id, striker
            ) as f,
            (
                SELECT match_id, season_id, season_year
                FROM match NATURAL JOIN season
            ) as g
        WHERE f.match_id = g.match_id
        ) as h,
        (SELECT match_id, season_id, season_year, bowler, wickets_match
        FROM
            (
                SELECT match_id, bowler, COUNT(player_out) as wickets_match
                FROM ball_by_ball NATURAL JOIN wicket_taken
                WHERE kind_out NOT IN (3,5,9)
                    AND innings_no IN (1,2)
                GROUP BY match_id, bowler
            ) as i,
            (
                SELECT match_id, season_id, season_year
                FROM match NATURAL JOIN season
            ) as j
        WHERE i.match_id = j.match_id
        ) as k
    WHERE g.match_id = k.match_id and g.striker = k.bowler
    GROUP BY g.season_id, g.striker, g.season_year
    HAVING SUM(runs_match)>=150 AND sum(wickets_match)>=5 AND COUNT(match_id)>=10
    ) as m,
    player, batting_style
WHERE player.player_id = m.player_id 
    AND batting_style.batting_id = player.batting_hand 
    AND batting_style.batting_skill = 'left'
ORDER BY m.num_wickets DESC, m.runs DESC, player.player_name, season_year;

--12--
SELECT match_id, player_name, team_name, num_wickets, season_year
FROM
    (SELECT pg.match_id, pg.player_name, pg.team_name, pg.season_year , pg.num_wickets
        row_number() OVER(PARTITION BY pg.season_year ORDER BY pg.num_wickets DESC) as rnk
    FROM
        (SELECT f.match_id, player_name, team.team_name, match.season_year , f.num_wickets
                row_number() over(partition by f.match_id ORDER BY f.num_wickets DESC) as rn
        FROM
            (SELECT match_id, bowler team_bowling, COUNT(player_out) as num_wickets
            FROM ball_by_ball NATURAL JOIN wicket_taken
            WHERE kind_out NOT IN (3,5,9) AND innings_no in (1,2)
            GROUP BY match_id , bowler, team_bowling
            ) as f 
                JOIN team ON team.team_id = f.team_bowling
                JOIN player on player.player_id = f.bowler
                JOIN match on match.match_id = f.match_id 
        )as pg
    WHERE rn = 1)
WHERE rnk = 1
ORDER BY num_wickets DESC, player_name;

--13--
SELECT player.player_name
FROM
    (
        SELECT p.player_id, COUNT(DISTINCT season_id) as season_played
        FROM
            (
                SELECT season_id, match_id
                FROM match NATURAL JOIN season) as a NATURAL JOIN player_match as p
        GROUP BY p.player_id) as f, 
    (
        SELECT COUNT(season_id) as total_seasons
        FROM season) as s , player
WHERE f.season_played = s.total_seasons AND player.player_id = f.player_id
ORDER BY player.player_name;

--14--
SELECT f.season_year, f.match_id, f.team_name
FROM 
    (SELECT season.season_year , x.match_id , team.team_name , x.req_players
        row_number() over(
            partition by season.season_year ORDER BY x.req_players DESC) AS  team_rank
    FROM    
        (SELECT f.season_id , f.match_id , f.team_batting ,
                COUNT(fifty_plus) as req_players
        FROM
            (SELECT b.match_id , b.innings_no , b.team_batting , 
                    b.striker , SUM(s.runs_scored) as fifty_plus
            FROM ball_by_ball as b NATURAL JOIN batsman_scored as s
            WHERE b.innings_no BETWEEN 1 AND 2
            GROUP by b.match_id , b.innings_no , b.striker, b.team_batting
            HAVING SUM(runs_scored) >= 50) as f, match as m
        WHERE m.match_id = f.match_id
        GROUP BY f.season_id , f.match_id , f.team_batting
        ) as x, team, season
    WHERE team.team_id = x.team_batting 
        AND season.season_id = x.season_id
    ) as t
WHERE t.team_rank <=3
ORDER BY t.season_year, t.req_players DESC, t.team_name;

--15--
SELECT season_year, top_batsman, max_runs, top_bowler, max_wickets
FROM
    (SELECT season_year, season_id, player_name as top_batsman, max_runs
    FROM
        (SELECT season.season_year , season.season_id, player.player_name,
                bat.max_runs,
                row_number() ORDER BY(PARTITION BY season.season_id 
                ORDER BY bat.max_runs DESC, player.player_name) as rn
        FROM 
            (SELECT f.striker, match.season_id, SUM(f.runs_scored) as max_runs
            FROM
                (SELECT match_id , striker , sum(runs_scored) as runs_match
                FROM ball_by_ball NATURAL JOIN batsman_scored
                WHERE innings_no in (1,2) 
                GROUP BY match_id , striker 
                ) as f
                JOIN match on match.match_id = f.match_id
            GROUP BY match.season_id, f.striker
            ) as bat
            JOIN season ON season.season_id = bat.season_id
            JOIN player ON player.player_id = bat.striker
        )
    WHERE rn = 2
    )as table1
    JOIN
    (SELECT season_year, season_id, player_name as top_bowler, max_wickets
    FROM
        (SELECT season.season_year , season.season_id, player.player_name,
                ball.max_wickets,
                row_number() ORDER BY(PARTITION BY season.season_id 
                ORDER BY ball.max_wickets DESC, player.player_name) as rnk
        FROM 
            (SELECT f.bowler, match.season_id, SUM(wicket_match) as max_wickets
            FROM
                (SELECT match_id , bowler , count(player_out) as wicket_match
                FROM ball_by_ball NATURAL JOIN wicket_taken
                WHERE innings_no in (1,2) AND kind_out NOT IN (3,5,9) 
                GROUP BY match_id , bowler 
                ) as f
                JOIN match on match.match_id = f.match_id
            GROUP BY match.season_id, f.bowler
            ) as ball
            JOIN season ON season.season_id = ball.season_id
            JOIN player ON player.player_id = ball.bowler
        )
    WHERE rnk = 2
    )as table2 
    ON table2.season_id = table1.season_id
ORDER BY season_year;

--16--
SELECT team.team_name
FROM
    (SELECT match.outcome_id , COUNT(match.match_id) as num_win
    FROM match NATURAL JOIN season
    WHERE season.season_year = 2008 
        AND match.outcome_id IS NOT NULL 
        AND (team_1 = 'Royal Challengers Bangalore' 
                OR match.team_2 = 'Royal Challengers Bangalore')
    GROUP BY match.outcome_id
    ) as f 
    JOIN team ON f.outcome_id = team.team_id
ORDER BY f.num_win DESC, team.team_name;

--17--
SELECT f.team_name, f.player_name, f.count
FROM
    (SELECT player.player_name, team.team_name, pf.num_man
            row_number() over(partition by(pf.player_id) ORDER BY pf.num_man DESC) as rn
    FROM 
        (SELECT player.player_id , player.team_id , COUNT(mp.match_id) as num_man
        FROM
            (SELECT match_id , man_of_the_match
            FROM match
            WHERE man_of_the_match is not NULL) as mp,
            INNER JOIN player_match 
            ON mp.match_id = player_match.match_id 
                AND mp.man_of_the_match = player.player_id
        GROUP BY player.player_id , player.team_id
        ) as pf 
        JOIN team on pf.team_id = team..team_id 
        JOIN player on pf.player_id = player.player_id
    ) as f
WHERE rn = 1
ORDER BY f.team_name, f.player_name;

--18--
SELECT player_name
FROM
    (SELECT f.player_id , COUNT(g.over_id) as freq
    FROM
        (SELECT player_id , COUNT(team_id) as num_team
        FROM player_match 
        GROUP BY player_id
        HAVING COUNT(team_id) >= 3) as f
        JOIN
        (SELECT over_id , bowler , SUM(runs_scored) as runs_conceeded
        FROM ball_by_ball 
            NATURAL JOIN wicket_taken 
            NATURAL JOIN batsman_scored
        GROUP BY over_id , bowler 
        HAVING SUM(runs_scored) >= 20) as g
        ON f.player_id = g.bowler
    GROUP BY f.player_id) as h, player
WHERE h.player_id = player.player_id
ORDER BY freq DESC , player_name
LIMIT 5;

--19--
SELECT team.team_name , f.avg_runs
FROM
    (SELECT mtr.team_batting , ROUND(AVG(mtr.match_runs),2)as avg_runs
    FROM 
        (SELECT match.match_id , season.season_id
        FROM match NATURAL JOIN season
        WHERE season.season_year = 2010
        ) AS ms,
        (SELECT bbb.team_batting , bs.match_id , SUM(bs.runs_scored) as match_runs
        FROM ball_by_ball as bbb NATURAL JOIN batsman_scored as bs
        WHERE bs.innings_no IN (1,2)
        GROUP BY bbb.team_batting, bs.match_id
        ) AS mtr
    WHERE mtr.match_id = ms.match_id
    GROUP BY mtr.team_batting
    ) as f 
        JOIN team ON f.team_batting = team.team_id
ORDER BY team.team_name, f.avg_runs;

--20--
SELECT player.player_name
FROM
    (SELECT f.player_out , count(f.match_id) as duck_out
    FROM
        (SELECT bbb.match_id , wt.player_out
        FROM ball_by_ball AS bbb NATURAL JOIN wicket_taken as wt
        WHERE bbb.over_id = 0 AND wt.player_out IS NOT NULL
                AND wt.innings_no IN (1,2)
        )as f
    GROUP BY f.player_out ) as fi , player
WHERE fi.player_out = player.player_id
ORDER BY fi.duck_out DESC , player.player_name;

--21--
SELECT final.match_id, t1.team_name as team_1_name, t3.team_name as team_2_name, t3.team_name as match_winner_name, final.num_of_boundaries
FROM
    (SELECT table2.match_id, table1.team_1, table1.team_2, table1.match_winner, table2.num_of_boundaries
    FROM
        (SELECT m.match_id, m.team_1, m.team_2, m.match_winner
        FROM match as m 
                JOIN win_by as wb on m.win_id = wb.win_id
        WHERE wb.win_id = "wickets"
        )as table1
        JOIN
        (SELECT bbb.match_id , bbb.team_batting , COUNT(bs.runs_scored) as num_of_boundaries
        FROM ball_by_ball as bbb NATURAL JOIN batsman_scored as bs
        WHERE bs.runs_scored IN (4,6) AND innings_no IN (1,2)
        GROUP BY bbb.match_id , bbb.team_batting
        ) as table2 ON table1.match_id = table2.team_batting
                    AND table1.match_winner = table2.team_batting
    )as final, team as t1, team as t2, team as t3
WHERE final.team_1 = t1.team_id
        AND final.team_2 = t2.team_id
        AND final.match_winner = t3.team_id
ORDER BY final.num_of_boundaries, t3.team_name, t1.team_name, t2.team_name
LIMIT 3;

--22--
