using System.Collections.Generic;

namespace againapi.Models
{
    public class User
    {
        public int Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string Password { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Role { get; set; } = "Customer";

        public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>(); 
        public ICollection<UserPoints> Points { get; set; } = new List<UserPoints>(); 

    }
}

