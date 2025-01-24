SELECT player_name, UNNEST(season_stats) AS season_stats 
FROM players 
WHERE player_name = 'Michael Jordan' AND current_season = 2001;

SELECT COUNT(*) FROM players WHERE current_season = 2001;
SELECT COUNT(*) FROM players; 

-- Unnested the season_stats 
WITH UNNESTED AS (
	SELECT player_name, UNNEST(season_stats) AS season_stats
	FROM players
	WHERE --player_name = 'Michael Jordan' AND 
	current_season = 2001
)

SELECT player_name, (season_stats:: season_stats).*
FROM UNNESTED;