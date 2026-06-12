using Expenses.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Expenses.Infrastructure.Persistence.Configurations;

public class ExpenseConfiguration : IEntityTypeConfiguration<Expense>
{
    public void Configure(EntityTypeBuilder<Expense> builder)
    {
        builder.ToTable("expenses", schema: "expenses");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.UserId).IsRequired();
        builder.Property(e => e.CategoryId).IsRequired();

        builder.Property(e => e.Title).IsRequired().HasMaxLength(150);
        builder.Property(e => e.Description).HasColumnType("text");
        builder.Property(e => e.Amount).HasColumnType("decimal(10,2)").IsRequired();
        
        builder.Property(e => e.ExpenseDate).HasColumnType("date").IsRequired();

        builder.Property(e => e.CreatedAt).HasDefaultValueSql("now()");
        builder.Property(e => e.UpdatedAt);

        builder.HasMany(e => e.Images)
            .WithOne()
            .HasForeignKey(img => img.ExpenseId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}