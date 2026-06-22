using MediatR;

namespace Categories.Application.Features.CreateCategory;

public record CreateCategoryCommand(
    Guid UserId,
    string Name,
    string? Icon,
    string? Color) : IRequest<Guid>;