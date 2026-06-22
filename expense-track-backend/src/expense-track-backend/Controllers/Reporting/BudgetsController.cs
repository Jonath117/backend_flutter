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
public class BudgetsController : ControllerBase
{
    private readonly IMediator _mediator;

    public BudgetsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetBudgets()
    {
        try
        {
            var userId = User.GetUserId();
            var query = new GetBudgetsQuery(userId);
            var budgets = await _mediator.Send(query);
            return Ok(budgets);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateBudget([FromBody] CreateBudgetRequest request)
    {
        try
        {
            var userId = User.GetUserId();
            
            DateOnly startDate = DateOnly.Parse(request.StartDate);
            DateOnly? endDate = string.IsNullOrEmpty(request.EndDate) ? null : DateOnly.Parse(request.EndDate);

            var command = new CreateBudgetCommand(
                userId,
                request.Name,
                request.MonthlyLimit,
                startDate,
                endDate,
                request.CategoryIds
            );

            var id = await _mediator.Send(command);
            return Created(string.Empty, new { Id = id, Message = "Presupuesto registrado correctamente" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateBudget(Guid id, [FromBody] UpdateBudgetRequest request)
    {
        try
        {
            var userId = User.GetUserId();
            DateOnly startDate = DateOnly.Parse(request.StartDate);
            DateOnly? endDate = string.IsNullOrEmpty(request.EndDate) ? null : DateOnly.Parse(request.EndDate);

            var command = new UpdateBudgetCommand(
                id,
                userId,
                request.Name,
                request.MonthlyLimit,
                startDate,
                endDate,
                request.CategoryIds
            );

            await _mediator.Send(command);
            return Ok(new { Message = "Presupuesto actualizado correctamente" });
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
    public async Task<IActionResult> DeleteBudget(Guid id)
    {
        try
        {
            var userId = User.GetUserId();
            var command = new DeleteBudgetCommand(id, userId);

            await _mediator.Send(command);
            return Ok(new { Message = "Presupuesto eliminado correctamente" });
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
