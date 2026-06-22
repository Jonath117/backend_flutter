using Categories.Domain.Entities;

namespace Categories.Application.Interfaces;

public interface ICategoryRepository
{
    Task AddAsync(Category category, CancellationToken cancellationToken);
    Task<IEnumerable<Category>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<bool> ExistsByNameAsync(Guid userId, string name, CancellationToken cancellationToken);
    Task SaveAsync(CancellationToken cancellationToken);
}