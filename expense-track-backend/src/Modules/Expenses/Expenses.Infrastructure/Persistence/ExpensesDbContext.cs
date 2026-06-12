using Expenses.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Expenses.Infrastructure.Persistence;

public class ExpensesDbContext : DbContext
{
    public ExpensesDbContext(DbContextOptions<ExpensesDbContext> options) : base(options)
    {
    }

    public DbSet<Expense> Expenses => Set<Expense>();
    public DbSet<ExpenseImage> ExpenseImages => Set<ExpenseImage>();
    public DbSet<Income> Incomes => Set<Income>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ExpensesDbContext).Assembly);
    }
}