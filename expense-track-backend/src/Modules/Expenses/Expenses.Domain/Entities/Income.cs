namespace Expenses.Domain.Entities;

public class Income
{
    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }
    
    public string Title { get; private set; } =  string.Empty;
    public decimal Amount { get; private set; }
    public DateOnly IncomeDate { get; private set; }
    
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }
    
    private Income() { }
    
    private Income(Guid userId, string title, decimal amount, DateOnly incomeDate)
    {
        Id = Guid.NewGuid();
        UserId = userId;
        Title = title;
        Amount = amount;
        IncomeDate = incomeDate;
        CreatedAt = DateTime.UtcNow;
    }
    
    public static Income Create(Guid userId, string title, decimal amount, DateOnly incomeDate)
    {
        if (userId == Guid.Empty) throw new ArgumentException("El usuario es requerido.");
        if (string.IsNullOrWhiteSpace(title)) throw new ArgumentException("El titulo no puede estar vacio.");
        if (amount <= 0) throw new ArgumentException("El monto del ingreso debe ser estrictamente mayor a cero.");

        return new Income(userId, title.Trim(), amount, incomeDate);
    }

    public void UpdateDetails(string title, decimal amount, DateOnly incomeDate)
    {
        if (string.IsNullOrWhiteSpace(title)) throw new ArgumentException("El titulo no puede estar vacio.");
        if (amount <= 0) throw new ArgumentException("El monto del ingreso debe ser estrictamente mayor a cero.");

        Title = title.Trim();
        Amount = amount;
        IncomeDate = incomeDate;
        UpdatedAt = DateTime.UtcNow;
    }
}