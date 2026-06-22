using System.Reflection;
using Microsoft.Extensions.DependencyInjection;

namespace Expenses.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddExpensesApplication(this IServiceCollection services)
    {
        services.AddMediatR(cfg => {
            cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
        });

        return services;
    }
}