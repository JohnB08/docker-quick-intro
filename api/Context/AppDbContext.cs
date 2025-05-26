using api.Entities;
using Microsoft.EntityFrameworkCore;

namespace api.Context;

public class AppDbContext(DbContextOptions options) : DbContext(options)
{
    public DbSet<EndpointCalled> Called { get; set; }
}