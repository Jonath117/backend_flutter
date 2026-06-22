using MediatR;
using Reporting.Application.Interfaces;

namespace Reporting.Application.Features.Commands;

public record DeleteBudgetCommand(Guid Id, Guid UserId) : IRequest;

public class DeleteBudgetCommandHandler : IRequestHandler<DeleteBudgetCommand>
{
    private readonly IBudgetRepository _budgetRepository;

    public DeleteBudgetCommandHandler(IBudgetRepository budgetRepository)
    {
        _budgetRepository = budgetRepository;
    }

    public async Task Handle(DeleteBudgetCommand request, CancellationToken cancellationToken)
    {
        var budget = await _budgetRepository.GetByIdAsync(request.Id);
        
        if (budget == null || budget.UserId != request.UserId) 
            throw new UnauthorizedAccessException("Presupuesto no encontrado o sin permisos.");
            
        await _budgetRepository.DeleteAsync(budget);
    }
}
