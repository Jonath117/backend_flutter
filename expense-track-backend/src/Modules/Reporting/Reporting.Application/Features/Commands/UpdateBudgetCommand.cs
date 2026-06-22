using MediatR;
using Reporting.Application.Interfaces;

namespace Reporting.Application.Features.Commands;

public record UpdateBudgetCommand(Guid Id, Guid UserId, string Name, decimal MonthlyLimit, DateOnly StartDate, DateOnly? EndDate, IEnumerable<Guid> CategoryIds) : IRequest;

public class UpdateBudgetCommandHandler : IRequestHandler<UpdateBudgetCommand>
{
    private readonly IBudgetRepository _budgetRepository;

    public UpdateBudgetCommandHandler(IBudgetRepository budgetRepository)
    {
        _budgetRepository = budgetRepository;
    }

    public async Task Handle(UpdateBudgetCommand request, CancellationToken cancellationToken)
    {
        var budget = await _budgetRepository.GetByIdAsync(request.Id);
        
        if (budget == null || budget.UserId != request.UserId) 
            throw new UnauthorizedAccessException("Presupuesto no encontrado o sin permisos.");
            
        var existingBudgets = await _budgetRepository.GetByUserIdAsync(request.UserId);
        foreach (var existing in existingBudgets)
        {
            if (existing.Id == request.Id) continue;

            bool overlap = false;
            if (request.EndDate == null && existing.EndDate == null) overlap = true;
            else if (request.EndDate == null && existing.EndDate != null) overlap = request.StartDate <= existing.EndDate.Value;
            else if (request.EndDate != null && existing.EndDate == null) overlap = existing.StartDate <= request.EndDate.Value;
            else overlap = request.StartDate <= existing.EndDate.Value && existing.StartDate <= request.EndDate.Value;

            if (overlap)
            {
                var sharedCategories = existing.BudgetCategories.Select(c => c.CategoryId).Intersect(request.CategoryIds);
                if (sharedCategories.Any())
                    throw new InvalidOperationException("Una categoría no puede estar en dos presupuestos con fechas que se solapan.");
            }
        }

        budget.Update(request.Name, request.MonthlyLimit, request.StartDate, request.EndDate);
        
        // Update categories
        var currentCategories = budget.BudgetCategories.Select(c => c.CategoryId).ToList();
        var toRemove = currentCategories.Except(request.CategoryIds).ToList();
        var toAdd = request.CategoryIds.Except(currentCategories).ToList();

        foreach (var id in toRemove) budget.RemoveCategory(id);
        foreach (var id in toAdd) budget.AddCategory(id);

        await _budgetRepository.UpdateAsync(budget);
    }
}
