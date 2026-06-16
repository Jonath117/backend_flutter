using Identity.Domain.Exceptions;

namespace Identity.Domain.Entities;

public class User
{
    public Guid Id { get; private set; }
    public String Email { get; private set; } = string.Empty;
    
    public String Name { get; private set; } = string.Empty;
    public String LastName { get; private set; } = string.Empty;
    public String PasswordHash { get; private set; } = string.Empty;
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }

    private User() { }

    private User(string email, string name, string lastName, string passwordHash)
    {
        Id = Guid.NewGuid();
        Email = email;
        Name = name;
        LastName = lastName;
        PasswordHash = passwordHash;
        CreatedAt = DateTime.UtcNow;
        UpdatedAt = DateTime.UtcNow;
    }

    public static User CreateUserManual(string email, string name, string lastName, string passwordHash)
    {
        ValidateData(email, name, lastName);
        
        if(string.IsNullOrWhiteSpace(passwordHash))
            throw new DomainException("la contrasena es requerida");
        
        return new User(email.Trim().ToLowerInvariant(), name.Trim(), lastName.Trim(), passwordHash);
    }

    private static void ValidateData(string email, string name, string lastName)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new DomainException("el Email es requerido");
        
        if (string.IsNullOrWhiteSpace(name))
            throw new DomainException("el Nombre es requerido");
        
        if (string.IsNullOrWhiteSpace(lastName))
            throw new DomainException("el Apellido es requerido");
    }

    public void UpdateName(string newName)
    {
        if(string.IsNullOrWhiteSpace(newName))
            throw new DomainException("el nuevo nombre es requerido");
        if(newName == Name)
            throw new DomainException("el nuevo nombre es igual al actual");
        
        Name = newName;
        UpdatedAt = DateTime.UtcNow;
    }

    public void UpdateLastName(string newLastName)
    {
        if(string.IsNullOrWhiteSpace(newLastName))
            throw new DomainException("el apellido es requerido");
        
        if(newLastName == LastName)
            throw new DomainException("el nuevo apellido es igual al actual");
        
        LastName = newLastName;
        UpdatedAt = DateTime.UtcNow;
    }
}