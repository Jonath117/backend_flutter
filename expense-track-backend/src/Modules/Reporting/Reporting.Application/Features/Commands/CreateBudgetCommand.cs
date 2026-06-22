using MediatR;
using Reporting.Application.Interfaces;
using Reporting.Domain.Entities;

namespace Reporting.Application.Features.Commands;

public record CreateBudgetCommand(Guid UserId, string Name, decimal MonthlyLimit, DateOnly StartDate, DateOnly? EndDate, IEnumerable<Guid> CategoryIds) : IRequest<Guid>;

public class CreateBudgetCommandHandler : IRequestHandler<CreateBudgetCommand, Guid>
{
    private readonly IBudgetRepository _budgetRepository;

    public CreateBudgetCommandHandler(IBudgetRepository budgetRepository)
    {
        _budgetRepository = budgetRepository;
    }

    public async Task<Guid> Handle(CreateBudgetCommand request, CancellationToken cancellationToken)
    {
        var existingBudgets = await _budgetRepository.GetByUserIdAsync(request.UserId);
        foreach (var existing in existingBudgets)
        {
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

        var budget = Budget.Create(request.UserId, request.Name, request.MonthlyLimit, request.StartDate, request.EndDate);
        foreach (var catId in request.CategoryIds)
        {
            budget.AddCategory(catId);
        }

        await _budgetRepository.AddAsync(budget);
        return budget.Id;
    }
}
