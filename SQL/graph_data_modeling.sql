CREATE TYPE vertex_type AS ENUM('player', 'team', 'game');

CREATE TYPE edge_type AS ENUM('plays_against', 'shares_team', 'plays_in', 'plays_on');

-- Player plays against a player
-- Player plays in a team
-- Player plays in a game
-- player shares_team with player2;

DROP TYPE vertex_type CASCADE;


CREATE TABLE vertices (
	identifier TEXT, -- player_name
	type vertex_type, -- player
	properties JSON, -- player info
	PRIMARY KEY(identifier, type)
);

-- 'plays_against', 'shares_team', 'plays_in', 'plays_on'
CREATE TABLE edges (
	subject_identifier TEXT,
	subject_type vertex_type,
	object_identifier TEXT,
	object_type vertex_type,
	edge_type edge_type,
	properties JSON,
	PRIMARY KEY(subject_identifier, subject_type, object_identifier, object_type, edge_type)
	);

SELECT * FROM games;

SELECT * FROM vertices;

'player', 'team', 'game'
-- GAMES vetex
INSERT INTO vertices
SELECT 
	game_id AS identifier,
	'game'::vertex_type AS vertex_type,
	json_build_object(
	'pts_home', pts_home,
	'pts_away', pts_away,
	'winning_team', CASE WHEN home_team_wins = 1 THEN home_team_id ELSE visitor_team_id END 
	) AS properties
FROM games;

-- PLAYERS vertex
INSERT INTO vertices
WITH player_agg AS(
	SELECT player_id AS identifier,
	MAX(player_name) AS player_name,
	COUNT(1) AS number_of_games,
	SUM(pts) AS total_points,
	ARRAY_AGG(DISTINCT team_id) AS teams
	FROM game_details
	GROUP BY player_id
)
SELECT 
	identifier, 
	'player':: vertex_type,
	json_build_object(
	'player_name', player_name,
	'number_of_games', number_of_games,
	'total_points', total_points,
	'teams', teams
	)
FROM player_agg;

-- TEAM vertex
SELECT * FROM 
WITH teams_deduped AS (
	SELECT *, ROW_NUMBER()OVER(PARTITION BY team_id) AS row_num
	FROM teams
)
--SELECT * FROM teams_deduped;
INSERT INTO vertices
	WITH teams_deduped AS (
		SELECT *, ROW_NUMBER() OVER (PARTITION BY team_id) AS row_num
		FROM teams
	)
	SELECT 
		team_id AS identifier,
		'team'::vertex_type AS vertx_type,
		json_build_object(
			'abbreviation', abbreviation,
			'nickname', nickname,
			'city', city,
			'arena', arena,
			'year_founded', yearfounded
		) AS properties
	FROM teams_deduped
	WHERE row_num = 1;

-- SELECT type, count(1)
-- FROM vertices GROUP BY(1);

-- PLAYER PLAYERS IN GAME
	INSERT INTO EDGES
	WITH deduped AS (
	    SELECT *, row_number() OVER (PARTITION BY player_id, game_id) AS row_num
	    FROM game_details
	)
	SELECT
	    player_id AS subject_identifier,
	    'player'::vertex_type AS subject_type,
	    game_id AS object_identifier,
	    'game'::vertex_type AS object_type,
	    'plays_in'::edge_type AS edge_type,
	    json_build_object(
	        'start_position', start_position,
	        'pts', pts,
	        'team_id', team_id,
	        'team_abbreviation', team_abbreviation
	    ) AS properties
	FROM deduped
	WHERE row_num = 1;


SELECT 
    v.properties->>'player_name',  -- Extract 'player_name' as text from JSON column `properties` of table `v`
    MAX(CAST(e.properties->>'pts' AS INTEGER))    -- Extract 'pts' as text from JSON column `properties` of table `e`, and get the MAX value
FROM vertices v
JOIN edges e
ON e.subject_identifier = v.identifier
AND e.subject_type = v.type
GROUP BY 1                         -- Grouping by the first column in SELECT
ORDER BY 2 DESC;                   -- Sorting the result by the second column (MAX points) in descending order
