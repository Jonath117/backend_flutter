using MediatR;
using Reporting.Application.Interfaces;

namespace Reporting.Application.Features.Commands;

public record UpdateGoalCommand(Guid Id, Guid UserId, string Name, decimal TargetAmount, DateOnly? TargetDate) : IRequest;

public class UpdateGoalCommandHandler : IRequestHandler<UpdateGoalCommand>
{
    private readonly IGoalRepository _goalRepository;

    public UpdateGoalCommandHandler(IGoalRepository goalRepository)
    {
        _goalRepository = goalRepository;
    }

    public async Task Handle(UpdateGoalCommand request, CancellationToken cancellationToken)
    {
        var goal = await _goalRepository.GetByIdAsync(request.Id);
        
        if (goal == null || goal.UserId != request.UserId) 
            throw new UnauthorizedAccessException("Meta no encontrada o sin permisos.");
            
        goal.UpdateTarget(request.Name, request.TargetAmount, request.TargetDate);
        await _goalRepository.UpdateAsync(goal);
    }
}
