using MediatR;

namespace Identity.Application.Features.Auth.Login;

public record LoginUserQuery(
    string Email,
    string Password) : IRequest<string>;