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
