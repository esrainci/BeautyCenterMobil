using System;

namespace againapi.Models
{
    public class Appointment
    {
        public int Id { get; set; } // Otomatik artan ID
        public string Service { get; set; } = string.Empty; // Hizmet adı
        public DateTime Date { get; set; } // Tarih ve saat
        public string Employee { get; set; } = string.Empty; // Çalışan adı (opsiyonel)
        public string UserEmail { get; set; } = string.Empty; // Kullanıcı e-posta adresi

    }
}

