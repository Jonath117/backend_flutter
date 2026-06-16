using Identity.Domain.Entities;

namespace Identity.Application.Interfaces;

public interface IUserRepository
{
    Task<bool> ExistsEmailAsync(string email, CancellationToken cancellationToken);
    
    Task AddAsync(User user, CancellationToken cancellationToken);
    
    Task SaveAsync(CancellationToken cancellationToken);
    
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken);
}