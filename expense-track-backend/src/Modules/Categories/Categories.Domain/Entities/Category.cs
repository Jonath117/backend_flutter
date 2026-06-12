namespace Categories.Domain.Entities;

public class Category
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    
    public required string Name { get; set; }
    public string? Icon { get; set; }
    public string? Color { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}