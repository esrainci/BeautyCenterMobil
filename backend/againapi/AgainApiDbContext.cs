using Microsoft.EntityFrameworkCore;
using againapi.Models;

namespace againapi
{
    public class AgainApiDbContext : DbContext
    {
        public AgainApiDbContext(DbContextOptions<AgainApiDbContext> options)
            : base(options)
        {
        }

        // Kullanıcı tablosu
        public DbSet<User> User { get; set; }

        // Randevu tablosu
        public DbSet<Appointment> Appointments { get; set; }

        // Kullanıcı puanları tablosu
        public DbSet<UserPoints> UserPoints { get; set; }

        // Favori hizmetler tablosu
        public DbSet<Favorite> Favorite { get; set; }

        // Kullanıcı yorumları tablosu
        public DbSet<UserReview> UserReviews { get; set; } // Bu satırı ekledik
    }
}


