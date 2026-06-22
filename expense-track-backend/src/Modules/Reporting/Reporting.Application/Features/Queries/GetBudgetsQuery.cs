using MediatR;
using Reporting.Application.Features.DTOs;
using Reporting.Application.Interfaces;

namespace Reporting.Application.Features.Queries;

public record GetBudgetsQuery(Guid UserId) : IRequest<IEnumerable<BudgetDto>>;

public class GetBudgetsQueryHandler : IRequestHandler<GetBudgetsQuery, IEnumerable<BudgetDto>>
{
    private readonly IBudgetRepository _budgetRepository;

    public GetBudgetsQueryHandler(IBudgetRepository budgetRepository)
    {
        _budgetRepository = budgetRepository;
    }

    public async Task<IEnumerable<BudgetDto>> Handle(GetBudgetsQuery request, CancellationToken cancellationToken)
    {
        var budgets = await _budgetRepository.GetByUserIdAsync(request.UserId);
        return budgets.Select(b => new BudgetDto(
            b.Id,
            b.UserId,
            b.Name,
            b.MonthlyLimit,
            b.StartDate,
            b.EndDate,
            b.BudgetCategories.Select(c => c.CategoryId),
            b.CreatedAt,
            b.UpdatedAt
        ));
    }
}
