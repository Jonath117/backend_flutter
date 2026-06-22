namespace Reporting.Application.Features.DTOs;

public record BudgetDto(
    Guid Id,
    Guid UserId,
    string Name,
    decimal MonthlyLimit,
    DateOnly StartDate,
    DateOnly? EndDate,
    IEnumerable<Guid> CategoryIds,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);
