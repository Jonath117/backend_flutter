namespace Reporting.Application.Interfaces;
using Reporting.Domain.Entities;

public interface IGoalRepository
{
    Task<Goal?> GetByIdAsync(Guid id);
    Task<IEnumerable<Goal>> GetByUserIdAsync(Guid userId);
    Task AddAsync(Goal goal);
    Task UpdateAsync(Goal goal);
    Task DeleteAsync(Goal goal);
}
