namespace NbaSummary.Models;

public sealed class TeamSummaryDto
{
    public string TeamName { get; set; } = "";
    public string TeamStadiumName { get; set; } = "";
    public string? TeamLogo { get; set; }
    public string SeasonMvpOnTeam { get; set; } = "";
    public int NumberOfGamesPlayed { get; set; }
    public int NumberOfGamesWon { get; set; }
    public int NumberOfGamesLost { get; set; }
    public int NumberPlayedHome { get; set; }
    public int NumberPlayedAway { get; set; }
    public string PointsInBiggestWin { get; set; } = "";
    public string PointsInBiggestLoss { get; set; } = "";
    public string LastGameStadiumName { get; set; } = "";
    public DateTime LastGameDate { get; set; }
}
