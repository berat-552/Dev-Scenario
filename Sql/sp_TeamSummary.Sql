USE NBA;
GO

CREATE OR ALTER PROCEDURE dbo.sp_TeamSummary
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH AllGames AS (
      -- Each row = one team's perspective of a game
      SELECT 
        t.TeamID,
        t.Name           AS TeamName,
        t.Stadium        AS TeamStadiumName,
        t.Logo           AS TeamLogo,
        g.GameID,
        g.GameDateTime,
        1                AS IsHome,
        0                AS IsAway,
        g.HomeScore      AS ScoreForTeam,
        g.AwayScore      AS ScoreOpp,
        g.HomeScore - g.AwayScore AS Margin
      FROM dbo.Teams t
      JOIN dbo.Games g ON g.HomeTeamID = t.TeamID

      UNION ALL

      SELECT 
        t.TeamID,
        t.Name,
        t.Stadium,
        t.Logo,
        g.GameID,
        g.GameDateTime,
        0,
        1,
        g.AwayScore,
        g.HomeScore,
        g.AwayScore - g.HomeScore
      FROM dbo.Teams t
      JOIN dbo.Games g ON g.AwayTeamID = t.TeamID
  ),
  Agg AS (
      SELECT
        TeamID,
        NumberOfGamesPlayed = COUNT(1),
        NumberOfGamesWon    = SUM(CASE WHEN Margin > 0 THEN 1 ELSE 0 END),
        NumberOfGamesLost   = SUM(CASE WHEN Margin < 0 THEN 1 ELSE 0 END),
        NumberPlayedHome    = SUM(IsHome),
        NumberPlayedAway    = SUM(IsAway),
        LastGameDateTime    = MAX(GameDateTime)
      FROM AllGames
      GROUP BY TeamID
  )
  SELECT 
    t.Name                                AS TeamName,
    t.Stadium                             AS TeamStadiumName,
    t.Logo                                 AS TeamLogo,
    -- MVP on team = player on that team's roster with the MOST MVP awards in Games
    ISNULL(mvp.MvpPlayerName, '')          AS SeasonMvpOnTeam,

    a.NumberOfGamesPlayed,
    a.NumberOfGamesWon,
    a.NumberOfGamesLost,
    a.NumberPlayedHome,
    a.NumberPlayedAway,

    bw.Scoreline                           AS PointsInBiggestWin,  -- e.g. 112-83 (team score first)
    bl.Scoreline                           AS PointsInBiggestLoss, -- e.g. 92-112  (team score first)

    lg.Stadium                             AS LastGameStadiumName, -- stadium of the HOME team in last game
    CAST(a.LastGameDateTime AS date)       AS LastGameDate
  FROM dbo.Teams t
  JOIN Agg a ON a.TeamID = t.TeamID

  -- Biggest win for this team (by margin)
  OUTER APPLY (
      SELECT TOP (1)
        CAST(ag.ScoreForTeam AS varchar(10)) + '-' + CAST(ag.ScoreOpp AS varchar(10)) AS Scoreline
      FROM AllGames ag
      WHERE ag.TeamID = t.TeamID AND ag.Margin > 0
      ORDER BY ag.Margin DESC, ag.GameDateTime DESC
  ) bw

  -- Biggest loss for this team (most negative margin)
  OUTER APPLY (
      SELECT TOP (1)
        CAST(ag.ScoreForTeam AS varchar(10)) + '-' + CAST(ag.ScoreOpp AS varchar(10)) AS Scoreline
      FROM AllGames ag
      WHERE ag.TeamID = t.TeamID AND ag.Margin < 0
      ORDER BY ag.Margin ASC, ag.GameDateTime DESC
  ) bl

  -- Last game: find latest game, then take the HOME team's stadium as the venue
  OUTER APPLY (
      SELECT TOP (1) g2.GameID, g2.HomeTeamID, g2.GameDateTime
      FROM dbo.Games g2
      WHERE g2.HomeTeamID = t.TeamID OR g2.AwayTeamID = t.TeamID
      ORDER BY g2.GameDateTime DESC
  ) lastg
  LEFT JOIN dbo.Teams ht ON ht.TeamID = lastg.HomeTeamID
  CROSS APPLY (SELECT ht.Stadium) lg

  -- MVP calculation: count how many times a rostered player was MVP in Games, pick the top one
  OUTER APPLY (
      SELECT TOP (1)
        p.Name AS MvpPlayerName,
        COUNT(g.GameID) AS MvpCount
      FROM dbo.Team_Player tp
      JOIN dbo.Players p ON p.PlayerID = tp.PlayerID
      LEFT JOIN dbo.Games g ON g.MVPPlayerID = p.PlayerID
      WHERE tp.TeamID = t.TeamID
      GROUP BY p.Name
      ORDER BY COUNT(g.GameID) DESC, p.Name
  ) mvp

  ORDER BY t.Name;
END
GO

-- Optional quick check (uncomment to run after creation):
-- EXEC dbo.sp_TeamSummary;
