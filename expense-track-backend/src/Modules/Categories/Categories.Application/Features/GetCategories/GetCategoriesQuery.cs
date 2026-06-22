using Categories.Domain.Entities;
using MediatR;

namespace Categories.Application.Features.GetCategories;

public record GetCategoriesQuery(Guid UserId) : IRequest<IEnumerable<CategoryDto>>;