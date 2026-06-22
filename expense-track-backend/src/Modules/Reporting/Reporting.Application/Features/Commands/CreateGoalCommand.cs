using MediatR;
using Reporting.Application.Interfaces;
using Reporting.Domain.Entities;

namespace Reporting.Application.Features.Commands;

public record CreateGoalCommand(Guid UserId, string Name, decimal TargetAmount, DateOnly? TargetDate) : IRequest<Guid>;

public class CreateGoalCommandHandler : IRequestHandler<CreateGoalCommand, Guid>
{
    private readonly IGoalRepository _goalRepository;

    public CreateGoalCommandHandler(IGoalRepository goalRepository)
    {
        _goalRepository = goalRepository;
    }

    public async Task<Guid> Handle(CreateGoalCommand request, CancellationToken cancellationToken)
    {
        var goal = Goal.Create(request.UserId, request.Name, request.TargetAmount, request.TargetDate);
        await _goalRepository.AddAsync(goal);
        return goal.Id;
    }
}
