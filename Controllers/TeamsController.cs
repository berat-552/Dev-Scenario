using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using NbaSummary.Models;
using System.Data;

namespace NbaSummary.Controllers;

public class TeamsController(IConfiguration cfg) : Controller
{
    private readonly string _connectionString = cfg.GetConnectionString("Default")!;

    public async Task<IActionResult> Index()
    {
        using var connection = new SqlConnection(_connectionString);
        var rows = await connection.QueryAsync<TeamSummaryDto>(
          "dbo.sp_TeamSummary",
          commandType: CommandType.StoredProcedure);

        return View(rows.ToList());
    }
}
