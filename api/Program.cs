using api.AppDbContext;
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


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapGet("RegisterEndpointCalled", async (AppDbContext context, ILogger<Program> logger) =>
{
    logger.LogInformation("Endpoint Called");
    await context.Called.AddAsync(new api.Entities.EndpointCalled { EndpointCalledDate = DateTime.Now });
    await context.SaveChangesAsync();
    logger.LogInformation("DateTime Added to database");
});

app.Run();

