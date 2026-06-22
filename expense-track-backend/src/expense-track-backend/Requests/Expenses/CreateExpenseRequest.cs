using System;
using System.Collections.Generic;

namespace expense_track_backend.Requests.Expenses;

public class CreateExpenseRequest
{
    public Guid CategoryId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Amount { get; set; }
    public DateOnly ExpenseDate { get; set; }
    public List<string> Images { get; set; } = new();
}
