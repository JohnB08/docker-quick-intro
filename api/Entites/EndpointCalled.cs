using System.ComponentModel.DataAnnotations;

namespace api.Entities;

public class EndpointCalled
{
    [Key]
    public int Id { get; set; }

    public DateTime EndpointCalledDate { get; set; }
}