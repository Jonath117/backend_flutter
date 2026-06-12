using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Reporting.Domain.Entities;

namespace Reporting.Infrastructure.Persistence.Configurations;

public class GoalConfiguration : IEntityTypeConfiguration<Goal>
{
    public void Configure(EntityTypeBuilder<Goal> builder)
    {
        builder.ToTable("goals", schema: "reporting");
        builder.HasKey(g => g.Id);

        builder.Property(g => g.UserId).IsRequired();
        builder.Property(g => g.Name).IsRequired().HasMaxLength(100);
        builder.Property(g => g.TargetAmount).HasColumnType("decimal(10,2)").IsRequired();
        builder.Property(g => g.CurrentAmount).HasColumnType("decimal(10,2)").HasDefaultValue(0m);
        builder.Property(g => g.TargetDate).HasColumnType("date");
        
        builder.Property(g => g.CreatedAt).HasDefaultValueSql("now()");
    }
}