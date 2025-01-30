namespace againapi.Models
{
    public class Favorite
    {
        public int Id { get; set; } // Otomatik artan ID
        public int UserId { get; set; } // Kullanıcı ile ilişkilendirme
        public string ServiceName { get; set; } = string.Empty; // Favori hizmet adı

        // İlişkisel veritabanı için User ile bağlantı
        public User? User { get; set; }

    }
}
