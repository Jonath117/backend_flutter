using Identity.Application.Interfaces;
using Identity.Domain.Exceptions;
using MediatR;

namespace Identity.Application.Features.Auth.Login;

public class UserLoginQueryHandler : IRequestHandler<LoginUserQuery, string>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtProvider _jwtProvider;

    public UserLoginQueryHandler(IUserRepository userRepository,  IPasswordHasher passwordHasher, IJwtProvider jwtProvider)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _jwtProvider = jwtProvider;
    }

    public async Task<string> Handle(LoginUserQuery request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email, cancellationToken);

        if (user == null)
            throw new DomainException("Credenciales Invalidas");

        var isPasswordValid = _passwordHasher.Verify(request.Password, user.PasswordHash);

        if (!isPasswordValid)
            throw new DomainException("Credenciales Invalidas");

        var token = _jwtProvider.GenerateJwt(user);
        
        return token;
    }
}