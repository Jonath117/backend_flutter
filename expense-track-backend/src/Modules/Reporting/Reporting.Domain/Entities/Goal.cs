namespace Reporting.Domain.Entities;

public class Goal
{
    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }
    
    public string Name { get; private set; } = string.Empty;
    public decimal TargetAmount { get; private set; }
    public decimal CurrentAmount { get; private set; }
    public DateOnly? TargetDate { get; private set; }
    
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }
    
    private Goal() { }
    
    private Goal(Guid userId, string name, decimal targetAmount, DateOnly? targetDate)
    {
        Id = Guid.NewGuid();
        UserId = userId;
        Name = name;
        TargetAmount = targetAmount;
        CurrentAmount = 0;
        TargetDate = targetDate;
        CreatedAt = DateTime.UtcNow;
    }
    
    public static Goal Create(Guid userId, string name, decimal targetAmount, DateOnly? targetDate = null)
    {
        if (userId == Guid.Empty) throw new ArgumentException("El usuario es requerido.");
        if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("El nombre de la meta no puede estar vacío.");
        if (targetAmount <= 0) throw new ArgumentException("El monto objetivo de la meta debe ser mayor a cero.");

        return new Goal(userId, name.Trim(), targetAmount, targetDate);
    }

    public void AddFunds(decimal amount)
    {
        if (amount <= 0) throw new ArgumentException("El monto a depositar debe ser mayor a cero.");
        
        CurrentAmount += amount;
        UpdatedAt = DateTime.UtcNow;
    }

    public void WithdrawFunds(decimal amount)
    {
        if (amount <= 0) throw new ArgumentException("El monto a retirar debe ser mayor a cero.");
        if (amount > CurrentAmount) throw new InvalidOperationException("No puedes retirar más fondos de los que tiene la meta actualmente.");

        CurrentAmount -= amount;
        UpdatedAt = DateTime.UtcNow;
    }

    public void UpdateTarget(string name, decimal newTargetAmount, DateOnly? newTargetDate)
    {
        if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("El nombre de la meta no puede estar vacío.");
        if (newTargetAmount <= 0) throw new ArgumentException("El monto objetivo debe ser mayor a cero.");

        Name = name.Trim();
        TargetAmount = newTargetAmount;
        TargetDate = newTargetDate;
        UpdatedAt = DateTime.UtcNow;
    }
}