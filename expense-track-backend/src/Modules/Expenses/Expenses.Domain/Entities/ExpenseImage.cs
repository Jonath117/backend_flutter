namespace Expenses.Domain.Entities;

public class ExpenseImage
{
    public Guid Id { get; private set; }
    public Guid ExpenseId { get; private set; }
    
    public string ImageUrl { get; private set; } = string.Empty;
    
    public DateTime CreatedAt { get; private set; }
    
    private ExpenseImage() { }
    
    private ExpenseImage(Guid expenseId, string imageUrl)
    {
        Id = Guid.NewGuid();
        ExpenseId = expenseId;
        ImageUrl = imageUrl;
        CreatedAt = DateTime.UtcNow;
    }

    internal static ExpenseImage Create(Guid expenseId, string imageUrl)
    {
        if (expenseId == Guid.Empty) 
            throw new ArgumentException("El ID del gasto es requerido.");
            
        if (string.IsNullOrWhiteSpace(imageUrl))
            throw new ArgumentException("La URL de la imagen es requerida.");

        return new ExpenseImage(expenseId, imageUrl.Trim());
    }
}