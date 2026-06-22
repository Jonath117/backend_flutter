using System.Text;
using Categories.Application;
using Categories.Infrastructure;
using DotNetEnv;
using Expenses.Application;
using Expenses.Infrastructure;
using Identity.Application;
using Identity.Infrastructure;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Reporting.Application;
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

var jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET") 
                ?? throw new InvalidOperationException("Falta JWT_SECRET");
var jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? "ExpenseTrackerAPI";
var jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? "ExpenseTrackerClients";

builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)) 
        };
    });

builder.Services.AddAuthorization();

builder.Services.AddIdentityInfrastructure(connectionString);
builder.Services.AddCategoriesInfrastructure(connectionString);
builder.Services.AddExpensesInfrastructure(connectionString);
builder.Services.AddReportingInfrastructure(connectionString);

builder.Services.AddIdentityApplication();
builder.Services.AddCategoriesApplication();
builder.Services.AddExpensesApplication();
builder.Services.AddReportingApplication();

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

var wwwrootPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
if (!Directory.Exists(wwwrootPath)) Directory.CreateDirectory(wwwrootPath);
app.UseCors("AllowAllLocal");
app.UseStaticFiles(new StaticFileOptions
{
    OnPrepareResponse = ctx =>
    {
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
    }
});

app.UseAuthentication();

//app.UseHttpsRedirection();

app.UseAuthorization();
app.MapControllers();
app.Run();