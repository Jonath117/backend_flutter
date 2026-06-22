using Expenses.Domain.Entities;

namespace Expenses.Application.Interfaces;

public interface IExpenseRepository
{
    Task<Expense?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<List<Expense>> GetAllAsync(Guid userId, Guid? categoryId = null, string? search = null, CancellationToken cancellationToken = default);
    Task AddAsync(Expense expense, CancellationToken cancellationToken = default);
    Task UpdateAsync(Expense expense, CancellationToken cancellationToken = default);
    Task DeleteAsync(Expense expense, CancellationToken cancellationToken = default);
}
