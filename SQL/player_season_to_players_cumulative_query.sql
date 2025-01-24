CREATE TYPE season_stats AS (
	season INTEGER,
	gp INTEGER,
	pts REAL,
	reb REAL,
	ast REAL
);

CREATE TYPE scoring_class AS ENUM('star', 'good', 'average', 'bad');

CREATE TABLE players (
    player_name TEXT,
    height TEXT,
    college TEXT,
    country TEXT,
    draft_year TEXT,
    draft_round TEXT,
    draft_number TEXT,
    season_stats season_stats[],
    scoring_class scoring_class,
    years_since_last_season INTEGER,
    current_season INTEGER,
	is_active BOOLEAN,
    PRIMARY KEY (player_name, current_season)
);

INSERT INTO players
WITH yesterday AS (
    SELECT * FROM players
    WHERE current_season = 2000 -- Starting from 1995 because min is 1996
),
today AS (
    SELECT * FROM player_seasons
    WHERE season = 2001 -- Starting from 1996 because min is 1996
)
SELECT
    COALESCE(t.player_name, y.player_name) AS player_name,
    COALESCE(t.height, y.height) AS height,
    COALESCE(t.college, y.college) AS college,
    COALESCE(t.country, y.country) AS country,
    COALESCE(t.draft_year, y.draft_year) AS draft_year,
    COALESCE(t.draft_round, y.draft_round) AS draft_round,
    COALESCE(t.draft_number, y.draft_number) AS draft_number,
    CASE 
        -- When starting, y will be null, so create the first value
        WHEN y.season_stats IS NULL 
        THEN ARRAY[ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
        -- When player is not retired
        WHEN t.season IS NOT NULL
        THEN y.season_stats || ARRAY[ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
        -- When player is retired and t season is NULL, keep y's season_stats
        ELSE y.season_stats
    END AS season_stats,
    CASE 
        -- If player is active in this season give me a label
        WHEN t.season IS NOT NULL THEN 
            CASE 
                WHEN t.pts > 20 THEN 'star'::scoring_class
                WHEN t.pts > 15 THEN 'good'::scoring_class
                WHEN t.pts > 10 THEN 'average'::scoring_class
                ELSE 'bad'::scoring_class
            END
        -- Else use the label of the last season
        ELSE y.scoring_class
    END AS scoring_class,
    CASE 
        -- If players played this season then 0
        WHEN t.season IS NOT NULL THEN 0
        -- Else add 1 to previous count
        ELSE y.years_since_last_season + 1
    END AS years_since_last_season,
    COALESCE(t.season, y.current_season + 1) AS current_season
FROM today t
FULL OUTER JOIN yesterday y
ON t.player_name = y.player_name;