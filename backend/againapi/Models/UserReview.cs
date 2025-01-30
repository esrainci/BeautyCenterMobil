namespace againapi.Models
{
    public class UserReview
    {
        public int Id { get; set; }
        public string UserEmail { get; set; } = string.Empty;  // Kullanıcının e-posta adresi
        public int Rating { get; set; }         // Puan (1-5 arası)
        public string Comment { get; set; } = string.Empty;   // Yorum
        public DateTime CreatedAt { get; set; } // Yorumun oluşturulma tarihi
    }
}
