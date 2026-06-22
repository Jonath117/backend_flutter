namespace expense_track_backend.Requests;

public record CreateCategoryRequest(string Name, string? Icon, string? Color);