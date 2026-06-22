using MediatR;
using Reporting.Application.Interfaces;
using Reporting.Domain.Entities;

namespace Reporting.Application.Features.Commands;

public record CreateBudgetCommand(Guid UserId, string Name, decimal MonthlyLimit, DateOnly StartDate, DateOnly? EndDate) : IRequest<Guid>;

public class CreateBudgetCommandHandler : IRequestHandler<CreateBudgetCommand, Guid>
{
    private readonly IBudgetRepository _budgetRepository;

    public CreateBudgetCommandHandler(IBudgetRepository budgetRepository)
    {
        _budgetRepository = budgetRepository;
    }

    public async Task<Guid> Handle(CreateBudgetCommand request, CancellationToken cancellationToken)
    {
        var budget = Budget.Create(request.UserId, request.Name, request.MonthlyLimit, request.StartDate, request.EndDate);
        await _budgetRepository.AddAsync(budget);
        return budget.Id;
    }
}
