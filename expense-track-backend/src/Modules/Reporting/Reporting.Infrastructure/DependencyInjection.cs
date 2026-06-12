using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Reporting.Infrastructure.Persistence;

namespace Reporting.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddReportingInfrastructure(this IServiceCollection services, string connectionString)
    {
        services.AddDbContext<ReportingDbContext>(options =>
            options.UseNpgsql(connectionString).UseSnakeCaseNamingConvention());

        return services;
    }
}