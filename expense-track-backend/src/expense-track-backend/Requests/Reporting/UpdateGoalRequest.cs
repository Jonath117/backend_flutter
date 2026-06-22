namespace expense_track_backend.Requests.Reporting;

public class UpdateGoalRequest
{
    public string Name { get; set; } = string.Empty;
    public decimal TargetAmount { get; set; }
    public string? TargetDate { get; set; }
}
