using MediatR;
using Reporting.Application.Interfaces;

namespace Reporting.Application.Features.Commands;

public record DeleteGoalCommand(Guid Id, Guid UserId) : IRequest;

public class DeleteGoalCommandHandler : IRequestHandler<DeleteGoalCommand>
{
    private readonly IGoalRepository _goalRepository;

    public DeleteGoalCommandHandler(IGoalRepository goalRepository)
    {
        _goalRepository = goalRepository;
    }

    public async Task Handle(DeleteGoalCommand request, CancellationToken cancellationToken)
    {
        var goal = await _goalRepository.GetByIdAsync(request.Id);
        
        if (goal == null || goal.UserId != request.UserId) 
            throw new UnauthorizedAccessException("Meta no encontrada o sin permisos.");
            
        await _goalRepository.DeleteAsync(goal);
    }
}
