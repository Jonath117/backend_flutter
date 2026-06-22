using Categories.Application.Interfaces;
using Categories.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Categories.Infrastructure.Persistence.Repositories;

public class CategoryRepository : ICategoryRepository
{
    private readonly CategoryDbContext _context;

    public CategoryRepository(CategoryDbContext context)
    {
        _context = context;
    }
    
    
    public async Task AddAsync(Category category, CancellationToken cancellationToken)
    {
        await _context.Categories.AddAsync(category, cancellationToken);
    }

    public async Task<IEnumerable<Category>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
    {
        return await  _context.Categories.
            Where(c => c.UserId == userId).
            OrderBy(c => c.Name).
            ToListAsync(cancellationToken);
    }

    public async Task<bool> ExistsByNameAsync(Guid userId, string name, CancellationToken cancellationToken)
    {
        return await _context.Categories.
            AnyAsync(c => c.UserId == userId && c.Name.ToLower() == name.ToLower(), cancellationToken);
    }

    public async Task SaveAsync(CancellationToken cancellationToken)
    {
        await  _context.SaveChangesAsync(cancellationToken);
    }
}