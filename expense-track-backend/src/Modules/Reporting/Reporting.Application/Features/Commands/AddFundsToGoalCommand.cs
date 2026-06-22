using MediatR;
using Reporting.Application.Interfaces;

namespace Reporting.Application.Features.Commands;

public record AddFundsToGoalCommand(Guid Id, Guid UserId, decimal Amount) : IRequest;

public class AddFundsToGoalCommandHandler : IRequestHandler<AddFundsToGoalCommand>
{
    private readonly IGoalRepository _goalRepository;

    public AddFundsToGoalCommandHandler(IGoalRepository goalRepository)
    {
        _goalRepository = goalRepository;
    }

    public async Task Handle(AddFundsToGoalCommand request, CancellationToken cancellationToken)
    {
        var goal = await _goalRepository.GetByIdAsync(request.Id);
        if (goal == null || goal.UserId != request.UserId) 
            throw new UnauthorizedAccessException("Meta no encontrada o sin permisos.");
            
        goal.AddFunds(request.Amount);
        await _goalRepository.UpdateAsync(goal);
    }
}
