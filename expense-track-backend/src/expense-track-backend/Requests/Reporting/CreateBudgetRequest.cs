namespace expense_track_backend.Requests.Reporting;

public class CreateBudgetRequest
{
    public string Name { get; set; } = string.Empty;
    public decimal MonthlyLimit { get; set; }
    public string StartDate { get; set; } = string.Empty;
    public string? EndDate { get; set; }
}
