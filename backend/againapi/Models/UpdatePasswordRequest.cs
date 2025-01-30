namespace againapi.Models
{
    public class UpdatePasswordRequest
    {
        public string CurrentPassword { get; set; } = string.Empty; // Mevcut şifre
        public string NewPassword { get; set; } = string.Empty;     // Yeni şifre
    }
}
