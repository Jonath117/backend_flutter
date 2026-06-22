using expense_track_backend.Extensions;
using expense_track_backend.Requests.Reporting;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Reporting.Application.Features.Commands;
using Reporting.Application.Features.Queries;

namespace expense_track_backend.Controllers.Reporting;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class GoalsController : ControllerBase
{
    private readonly IMediator _mediator;

    public GoalsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetGoals()
    {
        try
        {
            var userId = User.GetUserId();
            var query = new GetGoalsQuery(userId);
            var goals = await _mediator.Send(query);
            return Ok(goals);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateGoal([FromBody] CreateGoalRequest request)
    {
        try
        {
            var userId = User.GetUserId();
            DateOnly? targetDate = string.IsNullOrEmpty(request.TargetDate) ? null : DateOnly.Parse(request.TargetDate);

            var command = new CreateGoalCommand(
                userId,
                request.Name,
                request.TargetAmount,
                targetDate
            );

            var id = await _mediator.Send(command);
            return Created(string.Empty, new { Id = id, Message = "Meta registrada correctamente" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateGoal(Guid id, [FromBody] UpdateGoalRequest request)
    {
        try
        {
            var userId = User.GetUserId();
            DateOnly? targetDate = string.IsNullOrEmpty(request.TargetDate) ? null : DateOnly.Parse(request.TargetDate);

            var command = new UpdateGoalCommand(
                id,
                userId,
                request.Name,
                request.TargetAmount,
                targetDate
            );

            await _mediator.Send(command);
            return Ok(new { Message = "Meta actualizada correctamente" });
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteGoal(Guid id)
    {
        try
        {
            var userId = User.GetUserId();
            var command = new DeleteGoalCommand(id, userId);

            await _mediator.Send(command);
            return Ok(new { Message = "Meta eliminada correctamente" });
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }
    [HttpPost("{id:guid}/add-funds")]
    public async Task<IActionResult> AddFunds(Guid id, [FromBody] GoalFundsRequest request)
    {
        try
        {
            var userId = User.GetUserId();
            var command = new AddFundsToGoalCommand(id, userId, request.Amount);
            await _mediator.Send(command);
            return Ok(new { Message = "Fondos agregados correctamente" });
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPost("{id:guid}/withdraw-funds")]
    public async Task<IActionResult> WithdrawFunds(Guid id, [FromBody] GoalFundsRequest request)
    {
        try
        {
            var userId = User.GetUserId();
            var command = new WithdrawFundsFromGoalCommand(id, userId, request.Amount);
            await _mediator.Send(command);
            return Ok(new { Message = "Fondos retirados correctamente" });
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }
}
