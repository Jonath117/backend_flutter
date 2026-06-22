using System.Security.Claims;

namespace expense_track_backend.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal principal)
    {
        var userIdString = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        
        if (string.IsNullOrEmpty(userIdString))
            throw new UnauthorizedAccessException("Token invalido o no encontrado.");

        return Guid.Parse(userIdString);
    }
}