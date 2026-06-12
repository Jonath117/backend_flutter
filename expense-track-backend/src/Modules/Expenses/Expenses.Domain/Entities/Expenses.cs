namespace Expenses.Domain.Entities;

public class Expense
{
    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }
    public Guid CategoryId { get; private set; }
    
    public string Title { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public decimal Amount { get; private set; }
    public DateOnly ExpenseDate { get; private set; }
    
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }

    public ICollection<ExpenseImage> Images { get; private set; } = new List<ExpenseImage>();
}