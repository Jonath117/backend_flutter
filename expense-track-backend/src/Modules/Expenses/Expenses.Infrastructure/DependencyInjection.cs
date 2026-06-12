using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Expenses.Infrastructure.Persistence;

namespace Expenses.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddExpensesInfrastructure(this IServiceCollection services, string connectionString)
    {
        services.AddDbContext<ExpensesDbContext>(options =>
            options.UseNpgsql(connectionString).UseSnakeCaseNamingConvention());

        return services;
    }
}