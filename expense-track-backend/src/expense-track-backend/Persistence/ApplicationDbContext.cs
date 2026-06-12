using Microsoft.EntityFrameworkCore;

namespace expense_track_backend.Persistence;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(Identity.Infrastructure.Persistence.IdentityDbContext).Assembly);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(Categories.Infrastructure.Persistence.CategoryDbContext).Assembly);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(Expenses.Infrastructure.Persistence.ExpensesDbContext).Assembly);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(Reporting.Infrastructure.Persistence.ReportingDbContext).Assembly);
    }
}