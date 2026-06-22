using Microsoft.EntityFrameworkCore;
using Reporting.Application.Interfaces;
using Reporting.Domain.Entities;

namespace Reporting.Infrastructure.Persistence.Repositories;

public class BudgetRepository : IBudgetRepository
{
    private readonly ReportingDbContext _context;

    public BudgetRepository(ReportingDbContext context)
    {
        _context = context;
    }

    public async Task<Budget?> GetByIdAsync(Guid id)
    {
        return await _context.Budgets
            .Include(b => b.BudgetCategories)
            .FirstOrDefaultAsync(b => b.Id == id);
    }

    public async Task<IEnumerable<Budget>> GetByUserIdAsync(Guid userId)
    {
        return await _context.Budgets
            .Include(b => b.BudgetCategories)
            .Where(b => b.UserId == userId)
            .ToListAsync();
    }

    public async Task AddAsync(Budget budget)
    {
        await _context.Budgets.AddAsync(budget);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Budget budget)
    {
        _context.Budgets.Update(budget);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Budget budget)
    {
        _context.Budgets.Remove(budget);
        await _context.SaveChangesAsync();
    }
}
