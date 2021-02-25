--1--
SELECT match_id,player_name,team_name,num_wickets
FROM 
    (SELECT match_id, bowler, team_bowling, COUNT(player_out) AS num_wickets
    FROM ball_by_ball NATURAL JOIN wicket_taken
    WHERE kind_out NOT IN (3,5,9) AND innings_no in (1,2)
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
            match.man_of_the_match = player_match.player_id
    WHERE NOT player_match.team_id = match.match_winner
    GROUP BY player_match.player_id 
    ) as a
    JOIN player ON player.player_id = a.player_id
ORDER BY a.num_matches DESC, player_name
LIMIT 3;

--3--
SELECT player_name
FROM 
    (SELECT wt.fielders, COUNT(wt.player_out) as num_catches
    FROM ball_by_ball as bbb NATURAL JOIN wicket_taken as wt
            JOIN match ON match.match_id = bbb.match_id
            JOIN season ON season.season_id = match.season_id
            JOIN out_type ON out_type.out_id = wt.kind_out
    WHERE season_year = 2012 AND out_name = 'caught'  
    GROUP BY wt.fielders
    ) as f
    JOIN player ON player.player_id = f.fielders
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
SELECT DISTINCT player_name
FROM 
    (SELECT table1.striker
    FROM 
        (SELECT match_id, striker, team_batting , SUM(runs_scored) as vain
        FROM ball_by_ball NATURAL JOIN batsman_scored
        WHERE innings_no in (1,2)
        GROUP BY match_id , striker , team_batting
        HAVING SUM(runs_scored) > 50
        ) as table1 NATURAL JOIN match
    WHERE NOT table1.team_batting = match.match_winner
    )as f JOIN player ON f.striker = player.player_id
ORDER BY player_name;

--6--
SELECT h.season_year , h.team_name , h.rank
FROM
    (SELECT team_name, g.season_year,
            row_number() OVER (PARTITION BY season_year 
                    ORDER BY g.count_left_foreign_players DESC, team_name) as rank
    FROM 
        (SELECT fn.team_id , fn.season_year, COUNT(player_id) as count_left_foreign_players
        FROM 
            (SELECT player_id, f.season_year, team_id
            FROM 
                (SELECT match_id, season_year
                FROM match NATURAL JOIN season
                ) as f 
                    NATURAL JOIN player_match
            GROUP BY player_id, f.season_year, team_id
            )as fn NATURAL JOIN player
            JOIN batting_style ON batting_style.batting_id = player.batting_hand
            JOIN country ON country.country_id = player.country_id
        WHERE NOT country.country_name = 'India'
            AND batting_style.batting_hand = 'Left-hand bat'
        GROUP BY fn.team_id, fn.season_year
        )as g NATURAL JOIN team
    ) as h
WHERE h.rank <= 5
ORDER BY season_year, h.rank;

--7--
SELECT team_name 
FROM 
    (SELECT match_winner, season_id, COUNT(match_id) AS wins 
    FROM match NATURAL JOIN season
    WHERE outcome_id IS NOT NULL
        AND season_id IN (SELECT season_id
                            FROM season
                            WHERE season_year = 2009 )
    GROUP BY match_winner,season_id
    )as table1 JOIN team ON team.team_id = table1.match_winner
ORDER BY wins DESC, team_name;

--8--
SELECT team_name, player_name, runs_player as runs
FROM
    (SELECT team_id, player_id,team_name, player_name, runs_player,
        row_number() over(partition by team_id order by runs_player DESC) as rn 
    FROM 
        (SELECT team_id, player_id, team_name, player_name, SUM(runs_match) as runs_player
        FROM 
            (SELECT team_batting, striker, match_id, SUM(runs_scored) as runs_match
            FROM ball_by_ball NATURAL JOIN batsman_scored
            WHERE innings_no in (1,2)
            GROUP BY team_batting, striker, match_id
            )as f 
                JOIN team ON team.team_id=f.team_batting
                JOIN player ON player.player_id = f.striker
        WHERE match_id in (
                        SELECT match_id
                        FROM match NATURAL JOIN season
                        WHERE season_year = 2010
                    )
        GROUP BY team_id, player_id, team_name, player_name
        ) as fs
    )as fss
WHERE rn =1
ORDER BY team_name, player_name;

--9--
SELECT a.team_name, b.team_name as opponent_team_name, number_of_sixes as "number of sixes"
FROM (SELECT team_batting, team_bowling, number_of_sixes
    FROM
        (
            SELECT bbb.team_batting, bbb.team_bowling, bbb.match_id, COUNT(ball_id) as number_of_sixes
            FROM ball_by_ball as bbb NATURAL JOIN batsman_scored as bs
            WHERE bbb.innings_no IN (1,2) 
                AND bs.runs_scored = 6
            GROUP BY bbb.team_batting, bbb.team_bowling, bbb.match_id
        ) as f
        JOIN
        (
            SELECT match_id, season_id
            FROM match NATURAL JOIN season
            WHERE season_year = 2008
        ) as g ON f.match_id = g.match_id
    ) as h, team as a, team as b
WHERE h.team_batting = a.team_id AND h.team_bowling = b.team_id
ORDER BY "number of sixes" DESC, team_name
LIMIT 3;

--10--
SELECT final.bowling_skill as bowling_category, final.player_name, final.avg_runs as batting_average
FROM
    (SELECT table2.bowling_id, table2.bowling_skill, table4.avg_runs, table4.player_name,
            row_number() OVER(PARTITION BY table2.bowling_id ORDER BY table4.avg_runs DESC) as rn
    FROM
        (SELECT table1.bowling_id, table1.bowling_skill, ROUND(AVG(table1.all_wickets),2) as avg_category
        FROM
            (SELECT bs.bowling_id, player.player_id, bs.bowling_skill, COUNT(wt.player_out) as all_wickets  
            FROM ball_by_ball as bbb NATURAL JOIN wicket_taken as wt
                    JOIN player on player.player_id=bbb.bowler
                    JOIN bowling_style as bs ON bs.bowling_id=player.bowling_skill
            WHERE wt.kind_out NOT IN (3,5,9)
                    AND innings_no IN (1,2)
            GROUP BY bs.bowling_id, player.player_id, bs.bowling_skill
            HAVING COUNT(wt.player_out) > 0
            )as table1
        GROUP BY table1.bowling_id
        )as table2

        JOIN

        (SELECT table3.striker, player.bowling_id, player.player_name, ROUND(AVG(table3.tot_runs),2) as avg_runs
        FROM
            (SELECT bbb.striker, bbb.match_id, SUM(bs.runs_scored) as tot_runs
            FROM ball_by_ball as bbb NATURAL JOIN batsman_scored as bs
            WHERE bbb.innings_no IN (1,2)
            GROUP BY bbb.striker, bbb.match_id
            ) as table3 JOIN player ON player.player_id = table3.striker
        WHERE player.bowling_skill IS NOT NULL
        GROUP BY table3.striker, player.bowling_id, player.player_name
        )as table4 ON table2.bowling_id = table4.bowling_id
    WHERE table4.avg_runs > table2.avg_category
    )as final
WHERE rn=1;

--11--
SELECT m.season_year, player.player_name, m.num_wickets, m.runs
FROM
    (SELECT h.season_id, h.striker, h.season_year,
    SUM(runs_match) as runs, sum(wickets_match) as num_wickets, COUNT(h.match_id) 
    FROM
        (SELECT f.match_id, season_id, season_year, striker, runs_match
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
        (SELECT i.match_id, season_id, season_year, bowler, wickets_match
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
    WHERE h.match_id = k.match_id and h.striker = k.bowler
    GROUP BY h.season_id, h.striker, h.season_year
    HAVING SUM(h.runs_match)>=150 AND sum(k.wickets_match)>=5 AND COUNT(h.match_id)>=10
    ) as m 
        JOIN player ON player.player_id = m.striker
        JOIN batting_style ON batting_style.batting_id = player.batting_hand
                            AND batting_style.batting_hand = 'Left-hand bat'
ORDER BY m.num_wickets DESC, m.runs DESC, player.player_name, m.season_year;

--12--
SELECT match_id, player_name, team_name, num_wickets, season_year
FROM
    (SELECT pg.match_id, pg.player_name, pg.team_name, pg.season_year , pg.num_wickets,
        row_number() OVER(PARTITION BY pg.season_year ORDER BY pg.num_wickets DESC) as rnk
    FROM
        (SELECT f.match_id, player_name, team.team_name, season.season_year , f.num_wickets,
                row_number() over(partition by f.match_id ORDER BY f.num_wickets DESC) as rn
        FROM
            (SELECT match_id, bowler, team_bowling, COUNT(player_out) as num_wickets
            FROM ball_by_ball NATURAL JOIN wicket_taken
            WHERE kind_out NOT IN (3,5,9) AND innings_no in (1,2)
            GROUP BY match_id , bowler, team_bowling
            ) as f 
                JOIN team ON team.team_id = f.team_bowling
                JOIN player on player.player_id = f.bowler
                JOIN match on match.match_id = f.match_id
                JOIN season on season.season_id= match.season_id 
        )as pg
    WHERE rn = 1
    )as final
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
SELECT t.season_year, t.match_id, t.team_name
FROM 
    (SELECT season.season_year , x.match_id , team.team_name , x.req_players,
        row_number() over(
            partition by season.season_year ORDER BY x.req_players DESC) AS  team_rank
    FROM    
        (SELECT m.season_id , f.match_id , f.team_batting ,
                COUNT(fifty_plus) as req_players
        FROM
            (SELECT b.match_id , b.innings_no , b.team_batting , 
                    b.striker , SUM(s.runs_scored) as fifty_plus
            FROM ball_by_ball as b NATURAL JOIN batsman_scored as s
            WHERE b.innings_no IN (1,2)
            GROUP by b.match_id , b.innings_no , b.striker, b.team_batting
            HAVING SUM(runs_scored) >= 50
            ) as f 
            JOIN 
            (SELECT match_id, match_winner, season_id
            FROM match 
            WHERE match_winner is NOT NULL
            )as m ON m.match_id = f.match_id
        WHERE f.team_batting = m.match_winner
        GROUP BY m.season_id , f.match_id , f.team_batting
        ) as x 
            JOIN team ON team.team_id = x.team_batting
            JOIN season ON team.team_id = x.team_batting 
                    AND season.season_id = x.season_id
    ) as t
WHERE t.team_rank <=3
ORDER BY t.season_year, t.req_players DESC, t.team_name;

--15--
SELECT table1.season_year, top_batsman, max_runs, top_bowler, max_wickets
FROM
    (SELECT season_year, season_id, player_name as top_batsman, max_runs
    FROM
        (SELECT season.season_year , season.season_id, player.player_name,
                bat.max_runs,
                row_number() OVER(PARTITION BY season.season_id 
                ORDER BY bat.max_runs DESC, player.player_name) as rn
        FROM 
            (SELECT f.striker, match.season_id, SUM(f.runs_match) as max_runs
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
        ) as fs1
    WHERE rn = 2
    )as table1
    JOIN
    (SELECT season_year, season_id, player_name as top_bowler, max_wickets
    FROM
        (SELECT season.season_year , season.season_id, player.player_name,
                ball.max_wickets,
                row_number() over(PARTITION BY season.season_id 
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
        ) as fs2
    WHERE rnk = 2
    )as table2 
    ON table2.season_id = table1.season_id
ORDER BY season_year;

--16--
SELECT f.team_name
FROM
    (SELECT t3.team_name , COUNT(m.match_id) as num_win
    FROM(SELECT *
        FROM match
        WHERE match.match_winner IS NOT NULL
        ) as m 
            NATURAL JOIN season
            JOIN team as t1 ON t1.team_id = team_1
            JOIN team as t2 ON t2.team_id = team_2
            JOIN team as t3 ON t3.team_id = match_winner
    WHERE season.season_year = 2008 
        AND NOT t3.team_name = 'Royal Challengers Bangalore' 
        AND (t1.team_name = 'Royal Challengers Bangalore' 
                OR t2.team_name = 'Royal Challengers Bangalore')
    GROUP BY t3.team_name 
    ) as f 
ORDER BY f.num_win DESC, f.team_name;

--17--
SELECT f.team_name, f.player_name, f.num_man as count
FROM
    (SELECT player.player_name, team.team_name, pf.num_man,
            row_number() over(partition by team.team_name ORDER BY pf.num_man DESC,player.player_name) as rn
    FROM 
        (SELECT pm.player_id , pm.team_id , COUNT(mp.match_id) as num_man
        FROM
            (SELECT match_id , man_of_the_match
            FROM match
            WHERE man_of_the_match is not NULL
            ) as mp
            JOIN player_match as pm
                ON mp.match_id = pm.match_id 
                AND mp.man_of_the_match = pm.player_id
        GROUP BY pm.player_id , pm.team_id
        ) as pf 
        JOIN team on pf.team_id = team.team_id 
        JOIN player on pf.player_id = player.player_id
    ) as f
WHERE rn = 1
ORDER BY f.team_name;

--18--
SELECT player_name
FROM
    (SELECT f.player_id , COUNT(g.over_id) as freq
    FROM
        (SELECT player_id , COUNT(team_id) as num_team
        FROM player_match 
        GROUP BY player_id
        HAVING COUNT(team_id) >= 3
        ) AS f
        JOIN
        (SELECT over_id , bowler , SUM(runs_scored) as runs_conceeded
        FROM ball_by_ball 
            NATURAL JOIN batsman_scored
        GROUP BY over_id , bowler 
        HAVING SUM(runs_scored) >= 20
        ) AS g
            ON f.player_id = g.bowler
    GROUP BY f.player_id
    ) AS h JOIN player 
            ON h.player_id = player.player_id
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
SELECT player.player_name , fi.duck_out
FROM
    (SELECT f.player_out , count(f.match_id) as duck_out
    FROM
        (SELECT bbb.match_id , wt.player_out
        FROM ball_by_ball AS bbb NATURAL JOIN wicket_taken as wt
        WHERE bbb.over_id = 1
                AND wt.innings_no IN (1,2)
        )as f
    GROUP BY f.player_out
    ) as fi JOIN player ON fi.player_out = player.player_id
ORDER BY fi.duck_out DESC , player.player_name
LIMIT 10;

--21--
SELECT final.match_id, t1.team_name as team_1_name, t3.team_name as team_2_name, t3.team_name as match_winner_name, final.num_of_boundaries
FROM
    (SELECT table2.match_id, table1.team_1, table1.team_2, table1.match_winner, table2.num_of_boundaries
    FROM
        (SELECT m.match_id, m.team_1, m.team_2, m.match_winner
        FROM match as m 
                JOIN win_by as wb on m.win_id = wb.win_id
        WHERE wb.win_type = 'wickets'
        )as table1
        JOIN
        (SELECT bbb.match_id , bbb.team_batting , COUNT(bs.runs_scored) as num_of_boundaries
        FROM ball_by_ball as bbb NATURAL JOIN batsman_scored as bs
        WHERE bs.runs_scored IN (4,6) AND innings_no IN (1,2)
        GROUP BY bbb.match_id , bbb.team_batting
        )as table2 ON table1.match_id = table2.match_id
                    AND table1.match_winner = table2.team_batting
    )as final, team as t1, team as t2, team as t3
WHERE final.team_1 = t1.team_id
        AND final.team_2 = t2.team_id
        AND final.match_winner = t3.team_id
ORDER BY final.num_of_boundaries, t3.team_name, t1.team_name, t2.team_name
LIMIT 3;

--22--
SELECT foo.country_name
FROM
    (SELECT ROUND(table1.runs_conceeded/table2.wickets,2) as arc, 
            country.country_name, player.player_name
    FROM
        (SELECT match.season_id, bbb.bowler, SUM(bs.runs_scored) as runs_conceeded
        FROM ball_by_ball as bbb NATURAL JOIN batsman_scored as bs
                JOIN match on match.match_id = bbb.match_id
        WHERE innings_no in (1,2)
        GROUP BY match.season_id, bbb.bowler
        )AS table1
        JOIN
        (SELECT match.season_id, bbb.bowler, COUNT(wt.player_out) as wickets
        FROM ball_by_ball as bbb NATURAL JOIN wicket_taken as wt
                JOIN match on match.match_id = bbb.match_id
        WHERE innings_no in (1,2) AND wt.kind_out NOT IN(3,5,9)
        GROUP BY match.season_id, bbb.bowler
        HAVING COUNT(wt.player_out) >0
        )AS table2 ON table1.season_id = table2.season_id
                    AND table1.bowler = table2.bowler
        JOIN player ON player.player_id = table1.bowler
        JOIN country ON player.country_id = country.country_id
    )as foo
ORDER BY foo.arc ,foo.player_name
LIMIT 3;
