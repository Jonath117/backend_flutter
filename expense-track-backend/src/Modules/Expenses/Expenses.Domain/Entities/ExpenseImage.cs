namespace Expenses.Domain.Entities;

public class ExpenseImage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ExpenseId { get; set; }
    
    public required string ImageUrl { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}