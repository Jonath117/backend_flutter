namespace Reporting.Domain.Entities;

public class BudgetCategory
{
    public Guid BudgetId { get; private set; }
    public Guid CategoryId { get; private set; }
    
    private BudgetCategory(){ }
    
    private BudgetCategory(Guid budgetId, Guid categoryId)
    {
        BudgetId = budgetId;
        CategoryId = categoryId;
    }
    
    internal static BudgetCategory Create(Guid budgetId, Guid categoryId)
    {
        if (budgetId == Guid.Empty) throw new ArgumentException("El ID del presupuesto es requerido.");
        if (categoryId == Guid.Empty) throw new ArgumentException("El ID de la categoría es requerido.");

        return new BudgetCategory(budgetId, categoryId);
    }
}