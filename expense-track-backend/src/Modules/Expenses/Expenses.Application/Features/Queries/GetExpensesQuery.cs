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
