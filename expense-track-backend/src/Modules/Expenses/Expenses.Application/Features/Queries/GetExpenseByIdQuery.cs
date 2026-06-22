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
