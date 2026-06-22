using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Reporting.Application.Interfaces;
using Reporting.Infrastructure.Persistence;
using Reporting.Infrastructure.Persistence.Repositories;

namespace Reporting.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddReportingInfrastructure(this IServiceCollection services, string connectionString)
    {
        services.AddDbContext<ReportingDbContext>(options =>
            options.UseNpgsql(connectionString).UseSnakeCaseNamingConvention());

        services.AddScoped<IBudgetRepository,BudgetRepository>();
        services.AddScoped<IGoalRepository,GoalRepository>();

        return services;
    }
}