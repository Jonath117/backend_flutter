using Categories.Infrastructure;
using DotNetEnv;
using expense_track_backend.Persistence;
using Expenses.Infrastructure;
using Identity.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Reporting.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

var envPath = Path.Combine(builder.Environment.ContentRootPath, ".env");
Env.Load(envPath);
builder.Configuration.AddEnvironmentVariables();

var dbUser = Environment.GetEnvironmentVariable("DB_USER");
var dbPass = Environment.GetEnvironmentVariable("DB_PASSWORD");
var dbName = Environment.GetEnvironmentVariable("DB_NAME");
var dbPort = Environment.GetEnvironmentVariable("DB_PORT") ?? "5432";

var connectionString = $"Host=localhost;Port={dbPort};Database={dbName};Username={dbUser};Password={dbPass}";

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(connectionString).UseSnakeCaseNamingConvention());

builder.Services.AddIdentityInfrastructure(connectionString);
builder.Services.AddCategoriesInfrastructure(connectionString);
builder.Services.AddExpensesInfrastructure(connectionString);
builder.Services.AddReportingInfrastructure(connectionString);

builder.Services.AddMediatR(cfg => {
    cfg.RegisterServicesFromAssembly(typeof(Identity.Application.Features.Auth.Login.LoginUserQuery).Assembly);
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAllLocal", policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/openapi/v1.json", "Identity Module");
    });
}

app.UseCors("AllowAllLocal");

//app.UseHttpsRedirection();

app.UseAuthorization();
app.MapControllers();
app.Run();