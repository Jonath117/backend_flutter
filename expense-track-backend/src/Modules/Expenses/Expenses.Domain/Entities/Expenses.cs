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

    private readonly List<ExpenseImage> _images = new();
    public IReadOnlyCollection<ExpenseImage> Images => _images.AsReadOnly();
    
    
    private Expense(){ }
    
    private Expense(Guid userId, Guid categoryId, string title, string? description, decimal amount, DateOnly expenseDate)
    {
        Id = Guid.NewGuid();
        UserId = userId;
        CategoryId = categoryId;
        Title = title;
        Description = description;
        Amount = amount;
        ExpenseDate = expenseDate;
        CreatedAt = DateTime.UtcNow;
    }
    
    public static Expense Create(
        Guid userId,
        Guid categoryId,
        string title,
        string? description,
        decimal amount,
        DateOnly expenseDate)
    {
        if (userId == Guid.Empty) throw new ArgumentException("El usuario es requerido.");
        if (categoryId == Guid.Empty) throw new ArgumentException("La categoria es requerida.");
        if (string.IsNullOrWhiteSpace(title)) throw new ArgumentException("El titulo no puede estar vacio.");
        if (amount <= 0) throw new ArgumentException("El monto del gasto debe ser estrictamente mayor a cero.");

        return new Expense(userId, categoryId, title.Trim(), description?.Trim(), amount, expenseDate);
    }

    public void UpdateDetails(Guid categoryId, string title, string? description, decimal amount, DateOnly expenseDate)
    {
        if (categoryId == Guid.Empty) throw new ArgumentException("La categoria es requerida.");
        if (string.IsNullOrWhiteSpace(title)) throw new ArgumentException("El titulo no puede estar vacío.");
        if (amount <= 0) throw new ArgumentException("El monto del gasto debe ser estrictamente mayor a cero.");

        CategoryId = categoryId;
        Title = title.Trim();
        Description = description?.Trim();
        Amount = amount;
        ExpenseDate = expenseDate;
        UpdatedAt = DateTime.UtcNow;
    }

    public void AddImage(string imageUrl)
    {
        if (_images.Count >= 5) 
            throw new InvalidOperationException("No se pueden agregar más de 5 imágenes a un gasto.");

        var image = ExpenseImage.Create(Id, imageUrl);
        _images.Add(image);
        UpdatedAt = DateTime.UtcNow;
    }

    public void RemoveImage(Guid imageId)
    {
        var image = _images.FirstOrDefault(i => i.Id == imageId);
        if (image is null)
            throw new InvalidOperationException("La imagen no pertenece a este gasto o no existe.");

        _images.Remove(image);
        UpdatedAt = DateTime.UtcNow;
    }
}