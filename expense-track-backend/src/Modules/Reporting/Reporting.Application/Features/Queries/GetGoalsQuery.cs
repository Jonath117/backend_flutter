using MediatR;
using Reporting.Application.Features.DTOs;
using Reporting.Application.Interfaces;

namespace Reporting.Application.Features.Queries;

public record GetGoalsQuery(Guid UserId) : IRequest<IEnumerable<GoalDto>>;

public class GetGoalsQueryHandler : IRequestHandler<GetGoalsQuery, IEnumerable<GoalDto>>
{
    private readonly IGoalRepository _goalRepository;

    public GetGoalsQueryHandler(IGoalRepository goalRepository)
    {
        _goalRepository = goalRepository;
    }

    public async Task<IEnumerable<GoalDto>> Handle(GetGoalsQuery request, CancellationToken cancellationToken)
    {
        var goals = await _goalRepository.GetByUserIdAsync(request.UserId);
        return goals.Select(g => new GoalDto(
            g.Id,
            g.UserId,
            g.Name,
            g.TargetAmount,
            g.CurrentAmount,
            g.TargetDate,
            g.CreatedAt,
            g.UpdatedAt
        ));
    }
}
