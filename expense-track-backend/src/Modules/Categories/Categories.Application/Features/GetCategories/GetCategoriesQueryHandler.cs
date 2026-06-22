using Categories.Application.Interfaces;
using MediatR;

namespace Categories.Application.Features.GetCategories;

public class GetCategoriesQueryHandler : IRequestHandler<GetCategoriesQuery, IEnumerable<CategoryDto>>
{
    private readonly ICategoryRepository _categoryRepository;

    public GetCategoriesQueryHandler(ICategoryRepository categoryRepository)
    {
        _categoryRepository = categoryRepository;
    }

    public async Task<IEnumerable<CategoryDto>> Handle(GetCategoriesQuery request, CancellationToken cancellationToken)
    {
        var categories = await _categoryRepository.GetByUserIdAsync(request.UserId, cancellationToken);

        var dtos = categories.Select(c => new CategoryDto(
            c.Id,
            c.Name,
            c.Icon,
            c.Color
        ));
        
        return dtos;
    }
}