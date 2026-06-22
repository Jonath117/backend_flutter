namespace Reporting.Domain.Entities;

public class Budget
{
    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }
    
    public  string Name { get; private set; } = string.Empty;
    public decimal MonthlyLimit { get; private set; }
    public DateOnly StartDate { get; private set; }
    public DateOnly? EndDate { get; private set; }
    
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }

    private readonly List<BudgetCategory> _budgetCategories = new();
    public IReadOnlyCollection<BudgetCategory> BudgetCategories => _budgetCategories.AsReadOnly();
    
    private Budget() { }
    
    private Budget(Guid userId, string name, decimal monthlyLimit, DateOnly startDate, DateOnly? endDate)
    {
        Id = Guid.NewGuid();
        UserId = userId;
        Name = name;
        MonthlyLimit = monthlyLimit;
        StartDate = startDate;
        EndDate = endDate;
        CreatedAt = DateTime.UtcNow;
    }
    public static Budget Create(Guid userId, string name, decimal monthlyLimit, DateOnly startDate, DateOnly? endDate = null)
    {
        if (userId == Guid.Empty) throw new ArgumentException("El usuario es requerido.");
        if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("El nombre del presupuesto no puede estar vacío.");
        if (monthlyLimit <= 0) throw new ArgumentException("El límite mensual debe ser estrictamente mayor a cero.");
        
        if (endDate.HasValue && endDate.Value <= startDate)
            throw new ArgumentException("La fecha de finalización debe ser posterior a la fecha de inicio.");

        return new Budget(userId, name.Trim(), monthlyLimit, startDate, endDate);
    }

    public void AddCategory(Guid categoryId)
    {
        if (_budgetCategories.Any(bc => bc.CategoryId == categoryId))
            throw new InvalidOperationException("Esta categoría ya está asignada a este presupuesto.");

        var budgetCategory = BudgetCategory.Create(Id, categoryId);
        _budgetCategories.Add(budgetCategory);
        UpdatedAt = DateTime.UtcNow;
    }

    public void RemoveCategory(Guid categoryId)
    {
        var category = _budgetCategories.FirstOrDefault(bc => bc.CategoryId == categoryId);
        if (category is null)
            throw new InvalidOperationException("La categoria no pertenece a este presupuesto.");

        _budgetCategories.Remove(category);
        UpdatedAt = DateTime.UtcNow;
    }
}