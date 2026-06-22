using Microsoft.EntityFrameworkCore;
using Reporting.Application.Interfaces;
using Reporting.Domain.Entities;

namespace Reporting.Infrastructure.Persistence.Repositories;

public class GoalRepository : IGoalRepository
{
    private readonly ReportingDbContext _context;

    public GoalRepository(ReportingDbContext context)
    {
        _context = context;
    }

    public async Task<Goal?> GetByIdAsync(Guid id)
    {
        return await _context.Goals.FindAsync(id);
    }

    public async Task<IEnumerable<Goal>> GetByUserIdAsync(Guid userId)
    {
        return await _context.Goals
            .Where(g => g.UserId == userId)
            .ToListAsync();
    }

    public async Task AddAsync(Goal goal)
    {
        await _context.Goals.AddAsync(goal);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Goal goal)
    {
        _context.Goals.Update(goal);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Goal goal)
    {
        _context.Goals.Remove(goal);
        await _context.SaveChangesAsync();
    }
}
