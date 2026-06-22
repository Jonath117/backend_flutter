namespace Expenses.Application.Features.DTOs;

public record ExpenseDto(
    Guid Id,
    Guid CategoryId,
    string Title,
    string? Description,
    decimal Amount,
    DateOnly ExpenseDate,
    List<string> Images
);
