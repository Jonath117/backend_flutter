namespace Categories.Application.Features.GetCategories;

public record CategoryDto(
    Guid Id,
    string Name,
    string? Icon,
    string? Color);