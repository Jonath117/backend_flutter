namespace Categories.Domain.Entities;

public class Category
{
    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }

    public string Name { get; private set; } = string.Empty;
    public string? Icon { get; private set; }
    public string? Color { get; private set; }
    
    public DateTime CreatedAt { get; private set; } = DateTime.UtcNow;
    
    private Category() { }

    private Category(Guid userId, string name, string? icon, string? color)
    {
        Id =  Guid.NewGuid();
        UserId = userId;
        Name = name;
        Icon = icon;
        Color = color;
        CreatedAt = DateTime.UtcNow;
    }

    public static Category Create(Guid userId, string name, string? icon, string? color)
    {
        if (userId == Guid.Empty)
            throw new ArgumentException("El Id de usuario es requerido");

        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("El nombre es requerido");
        
        return new Category(userId, name, icon, color);
    }

    public void UpdateDetails(string name, string icon, string color)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("El nombre de la categoria no puede estar vacio");
        
        Name = name.Trim();
        Icon = icon.Trim();
        Color = color.Trim();
    }
}