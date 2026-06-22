using MediatR;
using Reporting.Application.Interfaces;

namespace Reporting.Application.Features.Commands;

public record WithdrawFundsFromGoalCommand(Guid Id, Guid UserId, decimal Amount) : IRequest;

public class WithdrawFundsFromGoalCommandHandler : IRequestHandler<WithdrawFundsFromGoalCommand>
{
    private readonly IGoalRepository _goalRepository;

    public WithdrawFundsFromGoalCommandHandler(IGoalRepository goalRepository)
    {
        _goalRepository = goalRepository;
    }

    public async Task Handle(WithdrawFundsFromGoalCommand request, CancellationToken cancellationToken)
    {
        var goal = await _goalRepository.GetByIdAsync(request.Id);
        if (goal == null || goal.UserId != request.UserId) 
            throw new UnauthorizedAccessException("Meta no encontrada o sin permisos.");
            
        goal.WithdrawFunds(request.Amount);
        await _goalRepository.UpdateAsync(goal);
    }
}
