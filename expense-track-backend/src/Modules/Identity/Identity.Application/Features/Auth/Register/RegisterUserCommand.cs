using MediatR;

namespace Identity.Application.Features.Auth.Register;

public record RegisterUserCommand(
    string Email,
    string Name,
    string LastName,
    string Password) : IRequest<Guid>;