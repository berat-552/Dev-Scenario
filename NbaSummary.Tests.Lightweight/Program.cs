using NbaSummary.Models;

namespace NbaSummary.Tests.Lightweight
{
    class Program
    {
        static void Main()
        {
            var dto = new TeamSummaryDto
            {
                NumberOfGamesPlayed = 10,
                NumberOfGamesWon = 6,
                NumberOfGamesLost = 4,
                SeasonMvpOnTeam = "LeBron James",
                TeamName = "Chicago Bulls",
                PointsInBiggestWin = "112-81"
            };

            RunTest("GamesPlayed = Wins + Losses",
                () => dto.NumberOfGamesPlayed == dto.NumberOfGamesWon + dto.NumberOfGamesLost);

            RunTest("MVP not empty",
                () => !string.IsNullOrWhiteSpace(dto.SeasonMvpOnTeam));

            RunTest("TeamName is Chicago Bulls",
                () => dto.TeamName == "Chicago Bulls");

            RunTest("Biggest win contains dash",
                () => dto.PointsInBiggestWin.Contains("-"));

            Console.WriteLine("✅ All tests complete!");
        }

        static void RunTest(string name, Func<bool> test)
        {
            if (test())
                Console.WriteLine($"[PASS] {name}");
            else
                Console.WriteLine($"[FAIL] {name}");
        }
    }
}
