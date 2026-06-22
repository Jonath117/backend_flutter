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
