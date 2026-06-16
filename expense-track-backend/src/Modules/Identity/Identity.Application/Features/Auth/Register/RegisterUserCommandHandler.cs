using Identity.Application.Interfaces;
using Identity.Domain.Entities;
using Identity.Domain.Exceptions;
using MediatR;

namespace Identity.Application.Features.Auth.Register;

public class RegisterUserCommandHandler : IRequestHandler<RegisterUserCommand, Guid>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;

    public RegisterUserCommandHandler(IUserRepository repository, IPasswordHasher passwordHasher)
    {
        _userRepository = repository;
        _passwordHasher = passwordHasher;
    }

    public async Task<Guid> Handle(RegisterUserCommand request, CancellationToken cancellationToken)
    {
        if (await _userRepository.ExistsEmailAsync(request.Email, cancellationToken))
            throw new DomainException("El email ya esta registrado");

        var hashedPassword = _passwordHasher.Hash(request.Password);

        var user = User.CreateUserManual(
            request.Email,
            request.Name,
            request.LastName,
            hashedPassword
        );
        
        await _userRepository.AddAsync(user, cancellationToken);
        await _userRepository.SaveAsync(cancellationToken);
        
        return user.Id;
    }
    
}