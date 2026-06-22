using System.Security.Claims;
using Expenses.Application.Features.Commands;
using Expenses.Application.Features.Queries;
using expense_track_backend.Requests.Expenses;
using expense_track_backend.Extensions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace expense_track_backend.Controllers.Expenses;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ExpensesController : ControllerBase
{
    private readonly IMediator _mediator;

    public ExpensesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetExpenses([FromQuery] Guid? categoryId, [FromQuery] string? search)
    {
        try
        {
            var userId = User.GetUserId();

            var query = new GetExpensesQuery(userId, categoryId, search);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetExpenseById(Guid id)
    {
        try
        {
            var query = new GetExpenseByIdQuery(id);
            var result = await _mediator.Send(query);
            
            if (result is null) return NotFound();
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateExpense([FromBody] CreateExpenseRequest request)
    {
        try
        {
            var userId = User.GetUserId();

            var command = new CreateExpenseCommand(
                userId,
                request.CategoryId,
                request.Title,
                request.Description,
                request.Amount,
                request.ExpenseDate,
                request.Images
            );

            var id = await _mediator.Send(command);
            return Created(string.Empty, new
            {
                Id = id,
                Message = "Gasto registrado correctamente"
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateExpense(Guid id, [FromBody] UpdateExpenseRequest request)
    {
        try
        {
            var command = new UpdateExpenseCommand(
                id,
                request.CategoryId,
                request.Title,
                request.Description,
                request.Amount,
                request.ExpenseDate,
                request.ImagesToAdd,
                request.ImagesToRemove
            );

            var success = await _mediator.Send(command);
            if (!success) return NotFound();

            return Ok(new { Message = "Gasto actualizado correctamente" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteExpense(Guid id)
    {
        try
        {
            var success = await _mediator.Send(new DeleteExpenseCommand(id));
            if (!success) return NotFound();

            return Ok(new { Message = "Gasto eliminado correctamente" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("upload-photo")]
    public async Task<IActionResult> UploadPhoto(IFormFile file)
    {
        try
        {
            if (file == null || file.Length == 0)
                return BadRequest(new { Message = "Archivo inválido o vacío." });

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            var uniqueFileName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var request = HttpContext.Request;
            var baseUrl = $"{request.Scheme}://{request.Host}{request.PathBase}";
            var fileUrl = $"{baseUrl}/uploads/{uniqueFileName}";

            return Ok(new { Url = fileUrl });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }
}
