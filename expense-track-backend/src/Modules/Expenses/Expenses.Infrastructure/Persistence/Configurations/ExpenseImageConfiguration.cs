using Expenses.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Expenses.Infrastructure.Persistence.Configurations;

public class ExpenseImageConfiguration : IEntityTypeConfiguration<ExpenseImage>
{
    public void Configure(EntityTypeBuilder<ExpenseImage> builder)
    {
        builder.ToTable("expense_images", schema: "expenses");
        builder.HasKey(img => img.Id);

        builder.Property(img => img.ExpenseId).IsRequired();
        builder.Property(img => img.ImageUrl).IsRequired().HasMaxLength(500);
        
        builder.Property(img => img.CreatedAt).HasDefaultValueSql("now()");
    }
}