using Categories.Application.Interfaces;
using Categories.Infrastructure.Persistence;
using Categories.Infrastructure.Persistence.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Categories.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddCategoriesInfrastructure(this IServiceCollection services,
        string connectionString)
    {
        services.AddDbContext<CategoryDbContext>(options => 
            options.UseNpgsql(connectionString).UseSnakeCaseNamingConvention());
        
        services.AddScoped<ICategoryRepository, CategoryRepository>();
        
        return services;
    }
}