namespace Reporting.Domain.Entities;

public class Goal
{
    public Guid Id { get; set; } =  Guid.NewGuid();
    public Guid UserId { get; set; }
    
    public required string Name { get; set; }
    public decimal TargetAmount { get; set; }
    public decimal CurrentAmount { get; set; } = 0;
    public DateOnly? TargetDate { get; set; }
    
    public DateTime CreatedAt { get; set; } =  DateTime.UtcNow;
}