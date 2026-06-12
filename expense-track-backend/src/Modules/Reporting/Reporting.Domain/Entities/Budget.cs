namespace Reporting.Domain.Entities;

public class Budget
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    
    public required string Name { get; set; }
    public decimal MonthlyLimit { get; set; }
    public DateOnly StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<BudgetCategory> BudgetCategories { get; set; } = new List<BudgetCategory>();
}