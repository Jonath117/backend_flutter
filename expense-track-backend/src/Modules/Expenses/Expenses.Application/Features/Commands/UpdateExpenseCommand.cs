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
