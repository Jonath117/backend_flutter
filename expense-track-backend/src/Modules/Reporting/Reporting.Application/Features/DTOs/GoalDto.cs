namespace Reporting.Application.Features.DTOs;

public record GoalDto(
    Guid Id,
    Guid UserId,
    string Name,
    decimal TargetAmount,
    decimal CurrentAmount,
    DateOnly? TargetDate,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);
