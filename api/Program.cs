using api.Context;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<AppDbContext>(
    options => options.UseSqlServer(builder.Configuration.GetConnectionString("Default"))
);
builder.Services.AddLogging();
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    try
    {
        await context.Database.MigrateAsync();
    }
    catch (Exception ex)
    {
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Something went wrong migrating the database");
    }
}

    app.UseHttpsRedirection();

app.MapGet("RegisterEndpointCalled", async (AppDbContext context, ILogger<Program> logger) =>
{
    logger.LogInformation("Endpoint Called");
    await context.Called.AddAsync(new api.Entities.EndpointCalled { EndpointCalledDate = DateTime.Now });
    await context.SaveChangesAsync();
    logger.LogInformation("DateTime Added to database");
});

app.MapHealthChecks("health");

app.Run();

