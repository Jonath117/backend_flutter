namespace Identity.Domain.Entities;

public class User
{
    public Guid Id { get; private set; }
    public String Email { get; private set; } = string.Empty;
    public String Username { get; private set; } = string.Empty;
    public String PasswordHash { get; private set; } = string.Empty;
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }
    
}