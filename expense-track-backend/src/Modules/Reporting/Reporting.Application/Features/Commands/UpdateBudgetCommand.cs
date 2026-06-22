using MediatR;
using Reporting.Application.Interfaces;

namespace Reporting.Application.Features.Commands;

public record UpdateBudgetCommand(Guid Id, Guid UserId, string Name, decimal MonthlyLimit, DateOnly StartDate, DateOnly? EndDate) : IRequest;

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
            
        budget.Update(request.Name, request.MonthlyLimit, request.StartDate, request.EndDate);
        await _budgetRepository.UpdateAsync(budget);
    }
}
