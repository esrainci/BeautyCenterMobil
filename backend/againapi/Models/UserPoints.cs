using System;

namespace againapi.Models
{
    public class UserPoints
    {
        public int Id { get; set; } // Otomatik artan ID
        public int UserId { get; set; } // Kullanıcı ile ilişkilendirme
        public int Points { get; set; } // Puan miktarı
        public DateTime EarnedDate { get; set; } // Puan kazanma tarihi

        // İlişkisel veritabanı için User ile bağlantı
        public User? User { get; set; }

    }
}
