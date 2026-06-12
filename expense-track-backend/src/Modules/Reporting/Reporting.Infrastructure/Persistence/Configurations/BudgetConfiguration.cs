using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Reporting.Domain.Entities;

namespace Reporting.Infrastructure.Persistence.Configurations;

public class BudgetConfiguration : IEntityTypeConfiguration<Budget>
{
    public void Configure(EntityTypeBuilder<Budget> builder)
    {
        builder.ToTable("budgets", schema: "reporting");
        builder.HasKey(b => b.Id);
        
        builder.Property(b => b.Name).IsRequired().HasMaxLength(100);
        builder.Property(b => b.MonthlyLimit).HasColumnType("decimal(10,2)").IsRequired();
        builder.Property(b => b.StartDate).HasColumnType("date").IsRequired();
        builder.Property(b => b.EndDate).HasColumnType("date");

        builder.OwnsMany(b => b.BudgetCategories, bc =>
        {
            bc.ToTable("budget_categories", schema: "reporting");
    
            bc.HasKey(x => new { x.BudgetId, x.CategoryId });
    
            bc.Property(x => x.CategoryId).HasColumnName("category_id");
            bc.Property(x => x.BudgetId).HasColumnName("budget_id");
    
            bc.WithOwner().HasForeignKey(x => x.BudgetId);
        });
    }
}