using Expenses.Application.Interfaces;
using Expenses.Domain.Entities;
using Expenses.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Expenses.Infrastructure.Repositories;

public class ExpenseRepository : IExpenseRepository
{
    private readonly ExpensesDbContext _context;

    public ExpenseRepository(ExpensesDbContext context)
    {
        _context = context;
    }

    public async Task<Expense?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.Expenses
            .Include(e => e.Images)
            .FirstOrDefaultAsync(e => e.Id == id, cancellationToken);
    }

    public async Task<List<Expense>> GetAllAsync(Guid userId, Guid? categoryId = null, string? search = null, CancellationToken cancellationToken = default)
    {
        var query = _context.Expenses
            .Include(e => e.Images)
            .Where(e => e.UserId == userId);

        if (categoryId.HasValue)
        {
            query = query.Where(e => e.CategoryId == categoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(e => e.Title.Contains(search) || (e.Description != null && e.Description.Contains(search)));
        }

        return await query.OrderByDescending(e => e.ExpenseDate).ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Expense expense, CancellationToken cancellationToken = default)
    {
        await _context.Expenses.AddAsync(expense, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Expense expense, CancellationToken cancellationToken = default)
    {
        _context.Expenses.Update(expense);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Expense expense, CancellationToken cancellationToken = default)
    {
        _context.Expenses.Remove(expense);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
