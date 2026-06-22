using Categories.Application.Interfaces;
using Categories.Domain.Entities;
using MediatR;

namespace Categories.Application.Features.CreateCategory;

public class CreateCategoryCommandHandler : IRequestHandler<CreateCategoryCommand, Guid>
{
    private readonly ICategoryRepository _categoryRepository;
    
    public CreateCategoryCommandHandler(ICategoryRepository categoryRepository)
    {
        _categoryRepository = categoryRepository;
    }

    public async Task<Guid> Handle(CreateCategoryCommand request, CancellationToken cancellationToken)
    {
        bool exists = await _categoryRepository.ExistsByNameAsync(request.UserId, request.Name, cancellationToken);
        if (exists)
            throw new ArgumentException($"Ya existe una categoria con el nombre: ${request.Name}");

        var category = Category.Create(
            request.UserId,
            request.Name,
            request.Icon,
            request.Color
        );
        
        await _categoryRepository.AddAsync(category, cancellationToken);
        await _categoryRepository.SaveAsync(cancellationToken);
        
        return category.Id;
    }
}