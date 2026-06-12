namespace Expenses.Domain.Entities;

public class Income
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    
    public required string Title { get; set; }
    public decimal Amount { get; set; }
    public DateOnly IncomeDate { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}