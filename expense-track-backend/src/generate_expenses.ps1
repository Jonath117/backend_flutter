$ErrorActionPreference = "Stop"

$baseDir = "C:\Users\MSI\Documents\U\7mo_semestre\PlataformasMoviles\ExpenseTrackerApp\expense-track-backend\src"
$appLayer = "$baseDir\Modules\Expenses\Expenses.Application"
$infraLayer = "$baseDir\Modules\Expenses\Expenses.Infrastructure"
$apiLayer = "$baseDir\expense-track-backend"

# 1. Create Interfaces
$interfacesDir = "$appLayer\Interfaces"
if (-not (Test-Path $interfacesDir)) { New-Item -ItemType Directory -Path $interfacesDir | Out-Null }

$iExpenseRepo = @"
using Expenses.Domain.Entities;

namespace Expenses.Application.Interfaces;

public interface IExpenseRepository
{
    Task<Expense?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<List<Expense>> GetAllAsync(Guid userId, Guid? categoryId = null, string? search = null, CancellationToken cancellationToken = default);
    Task AddAsync(Expense expense, CancellationToken cancellationToken = default);
    Task UpdateAsync(Expense expense, CancellationToken cancellationToken = default);
    Task DeleteAsync(Expense expense, CancellationToken cancellationToken = default);
}
"@
Set-Content -Path "$interfacesDir\IExpenseRepository.cs" -Value $iExpenseRepo

# 2. Create Repository Implementation
$repoDir = "$infraLayer\Repositories"
if (-not (Test-Path $repoDir)) { New-Item -ItemType Directory -Path $repoDir | Out-Null }

$expenseRepo = @"
using Expenses.Application.Interfaces;
using Expenses.Domain.Entities;
using Expenses.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Expenses.Infrastructure.Repositories;

public class ExpenseRepository : IExpenseRepository
{
    private readonly ExpensesDbContext _context;

    public ExpenseRepository(ExpensesDbContext context)
    {
        _context = context;
    }

    public async Task<Expense?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.Expenses
            .Include(e => e.Images)
            .FirstOrDefaultAsync(e => e.Id == id, cancellationToken);
    }

    public async Task<List<Expense>> GetAllAsync(Guid userId, Guid? categoryId = null, string? search = null, CancellationToken cancellationToken = default)
    {
        var query = _context.Expenses
            .Include(e => e.Images)
            .Where(e => e.UserId == userId);

        if (categoryId.HasValue)
        {
            query = query.Where(e => e.CategoryId == categoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(e => e.Title.Contains(search) || (e.Description != null && e.Description.Contains(search)));
        }

        return await query.OrderByDescending(e => e.ExpenseDate).ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Expense expense, CancellationToken cancellationToken = default)
    {
        await _context.Expenses.AddAsync(expense, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Expense expense, CancellationToken cancellationToken = default)
    {
        _context.Expenses.Update(expense);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Expense expense, CancellationToken cancellationToken = default)
    {
        _context.Expenses.Remove(expense);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
"@
Set-Content -Path "$repoDir\ExpenseRepository.cs" -Value $expenseRepo

# 3. Create Features (MediatR)
$featuresDir = "$appLayer\Features"
if (-not (Test-Path $featuresDir)) { New-Item -ItemType Directory -Path $featuresDir | Out-Null }

$dtosDir = "$featuresDir\DTOs"
if (-not (Test-Path $dtosDir)) { New-Item -ItemType Directory -Path $dtosDir | Out-Null }

$expenseDto = @"
namespace Expenses.Application.Features.DTOs;

public record ExpenseDto(
    Guid Id,
    Guid CategoryId,
    string Title,
    string? Description,
    decimal Amount,
    DateOnly ExpenseDate,
    List<string> Images
);
"@
Set-Content -Path "$dtosDir\ExpenseDto.cs" -Value $expenseDto

$getExpensesQuery = @"
using Expenses.Application.Features.DTOs;
using Expenses.Application.Interfaces;
using MediatR;

namespace Expenses.Application.Features.Queries;

public record GetExpensesQuery(Guid UserId, Guid? CategoryId, string? Search) : IRequest<List<ExpenseDto>>;

public class GetExpensesQueryHandler : IRequestHandler<GetExpensesQuery, List<ExpenseDto>>
{
    private readonly IExpenseRepository _repository;

    public GetExpensesQueryHandler(IExpenseRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<ExpenseDto>> Handle(GetExpensesQuery request, CancellationToken cancellationToken)
    {
        var expenses = await _repository.GetAllAsync(request.UserId, request.CategoryId, request.Search, cancellationToken);
        
        return expenses.Select(e => new ExpenseDto(
            e.Id,
            e.CategoryId,
            e.Title,
            e.Description,
            e.Amount,
            e.ExpenseDate,
            e.Images.Select(i => i.ImageUrl).ToList()
        )).ToList();
    }
}
"@
$queriesDir = "$featuresDir\Queries"
if (-not (Test-Path $queriesDir)) { New-Item -ItemType Directory -Path $queriesDir | Out-Null }
Set-Content -Path "$queriesDir\GetExpensesQuery.cs" -Value $getExpensesQuery

$getExpenseByIdQuery = @"
using Expenses.Application.Features.DTOs;
using Expenses.Application.Interfaces;
using MediatR;

namespace Expenses.Application.Features.Queries;

public record GetExpenseByIdQuery(Guid Id) : IRequest<ExpenseDto?>;

public class GetExpenseByIdQueryHandler : IRequestHandler<GetExpenseByIdQuery, ExpenseDto?>
{
    private readonly IExpenseRepository _repository;

    public GetExpenseByIdQueryHandler(IExpenseRepository repository)
    {
        _repository = repository;
    }

    public async Task<ExpenseDto?> Handle(GetExpenseByIdQuery request, CancellationToken cancellationToken)
    {
        var expense = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (expense is null) return null;

        return new ExpenseDto(
            expense.Id,
            expense.CategoryId,
            expense.Title,
            expense.Description,
            expense.Amount,
            expense.ExpenseDate,
            expense.Images.Select(i => i.ImageUrl).ToList()
        );
    }
}
"@
Set-Content -Path "$queriesDir\GetExpenseByIdQuery.cs" -Value $getExpenseByIdQuery


$commandsDir = "$featuresDir\Commands"
if (-not (Test-Path $commandsDir)) { New-Item -ItemType Directory -Path $commandsDir | Out-Null }

$createExpenseCommand = @"
using Expenses.Application.Interfaces;
using Expenses.Domain.Entities;
using MediatR;

namespace Expenses.Application.Features.Commands;

public record CreateExpenseCommand(
    Guid UserId,
    Guid CategoryId,
    string Title,
    string? Description,
    decimal Amount,
    DateOnly ExpenseDate,
    List<string> Images) : IRequest<Guid>;

public class CreateExpenseCommandHandler : IRequestHandler<CreateExpenseCommand, Guid>
{
    private readonly IExpenseRepository _repository;

    public CreateExpenseCommandHandler(IExpenseRepository repository)
    {
        _repository = repository;
    }

    public async Task<Guid> Handle(CreateExpenseCommand request, CancellationToken cancellationToken)
    {
        var expense = Expense.Create(
            request.UserId,
            request.CategoryId,
            request.Title,
            request.Description,
            request.Amount,
            request.ExpenseDate);

        if (request.Images != null)
        {
            foreach (var imageUrl in request.Images)
            {
                expense.AddImage(imageUrl);
            }
        }

        await _repository.AddAsync(expense, cancellationToken);
        return expense.Id;
    }
}
"@
Set-Content -Path "$commandsDir\CreateExpenseCommand.cs" -Value $createExpenseCommand

$updateExpenseCommand = @"
using Expenses.Application.Interfaces;
using MediatR;

namespace Expenses.Application.Features.Commands;

public record UpdateExpenseCommand(
    Guid Id,
    Guid CategoryId,
    string Title,
    string? Description,
    decimal Amount,
    DateOnly ExpenseDate,
    List<string> ImagesToAdd,
    List<Guid> ImagesToRemove) : IRequest<bool>;

public class UpdateExpenseCommandHandler : IRequestHandler<UpdateExpenseCommand, bool>
{
    private readonly IExpenseRepository _repository;

    public UpdateExpenseCommandHandler(IExpenseRepository repository)
    {
        _repository = repository;
    }

    public async Task<bool> Handle(UpdateExpenseCommand request, CancellationToken cancellationToken)
    {
        var expense = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (expense is null) return false;

        expense.UpdateDetails(
            request.CategoryId,
            request.Title,
            request.Description,
            request.Amount,
            request.ExpenseDate);

        if (request.ImagesToRemove != null)
        {
            foreach (var imageId in request.ImagesToRemove)
            {
                expense.RemoveImage(imageId);
            }
        }

        if (request.ImagesToAdd != null)
        {
            foreach (var imageUrl in request.ImagesToAdd)
            {
                expense.AddImage(imageUrl);
            }
        }

        await _repository.UpdateAsync(expense, cancellationToken);
        return true;
    }
}
"@
Set-Content -Path "$commandsDir\UpdateExpenseCommand.cs" -Value $updateExpenseCommand

$deleteExpenseCommand = @"
using Expenses.Application.Interfaces;
using MediatR;

namespace Expenses.Application.Features.Commands;

public record DeleteExpenseCommand(Guid Id) : IRequest<bool>;

public class DeleteExpenseCommandHandler : IRequestHandler<DeleteExpenseCommand, bool>
{
    private readonly IExpenseRepository _repository;

    public DeleteExpenseCommandHandler(IExpenseRepository repository)
    {
        _repository = repository;
    }

    public async Task<bool> Handle(DeleteExpenseCommand request, CancellationToken cancellationToken)
    {
        var expense = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (expense is null) return false;

        await _repository.DeleteAsync(expense, cancellationToken);
        return true;
    }
}
"@
Set-Content -Path "$commandsDir\DeleteExpenseCommand.cs" -Value $deleteExpenseCommand

# 4. Controller
$controllersDir = "$apiLayer\Controllers"
if (-not (Test-Path $controllersDir)) { New-Item -ItemType Directory -Path $controllersDir | Out-Null }

$expenseController = @"
using Expenses.Application.Features.Commands;
using Expenses.Application.Features.Queries;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace expense_track_backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ExpensesController : ControllerBase
{
    private readonly IMediator _mediator;

    public ExpensesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetExpenses([FromQuery] Guid userId, [FromQuery] Guid? categoryId, [FromQuery] string? search)
    {
        // NOTE: userId should normally come from authenticated user context, 
        // passing it as a query param just for simplicity based on the model if auth is not fully configured.
        if (userId == Guid.Empty) return BadRequest("UserId is required.");

        var query = new GetExpensesQuery(userId, categoryId, search);
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetExpenseById(Guid id)
    {
        var query = new GetExpenseByIdQuery(id);
        var result = await _mediator.Send(query);
        
        if (result is null) return NotFound();
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateExpense([FromBody] CreateExpenseCommand command)
    {
        var id = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetExpenseById), new { id = id }, new { id });
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateExpense(Guid id, [FromBody] UpdateExpenseCommand command)
    {
        if (id != command.Id) return BadRequest("ID in path does not match ID in body.");

        var success = await _mediator.Send(command);
        if (!success) return NotFound();

        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteExpense(Guid id)
    {
        var success = await _mediator.Send(new DeleteExpenseCommand(id));
        if (!success) return NotFound();

        return NoContent();
    }
}
"@
Set-Content -Path "$controllersDir\ExpensesController.cs" -Value $expenseController

Write-Output "Backend generation complete."
