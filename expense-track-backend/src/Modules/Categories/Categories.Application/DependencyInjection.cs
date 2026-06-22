using System.Reflection;
using Microsoft.Extensions.DependencyInjection;

namespace Categories.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddCategoriesApplication(this IServiceCollection services)
    {
        services.AddMediatR(cfg => {
            cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
        });

        return services;
    }
}