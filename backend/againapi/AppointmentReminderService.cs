using againapi;
using againapi.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

public class AppointmentReminderService
{
    private AgainApiDbContext _context;

    public AppointmentReminderService(AgainApiDbContext context)
    {
        _context = context;
    }

    // Randevu hatırlatmalarını gönderir
    public async Task SendAppointmentRemindersAsync()
    {
        var now = DateTime.Now;
        var reminderTime = now.AddHours(1); // Randevudan 1 saat önceki zamanı belirleyin

        // Veritabanından, hatırlatma zamanı yaklaşan randevuları çekeriz
        var appointments = await _context.Appointments
            .Where(a => a.Date <= reminderTime && a.Date > now)
            .ToListAsync();

        foreach (var appointment in appointments)
        {
            // Randevudaki kullanıcı bilgilerini alırız
            var user = await _context.User
                .FirstOrDefaultAsync(u => u.Email == appointment.UserEmail);

            if (user != null)
            {
                // SMS ve e-posta hatırlatmalarını göndeririz
                await SendSmsReminderAsync(user.Phone, appointment);
                await SendEmailReminderAsync(user.Email, appointment);
            }
        }
    }

    // SMS hatırlatmasını gönderir
    private async Task SendSmsReminderAsync(string? phoneNumber, Appointment appointment)
    {
        if (!string.IsNullOrEmpty(phoneNumber))
        {
            var messageBody = $"Randevunuz {appointment.Date} tarihinde yapılacaktır. Hizmet: {appointment.Service}";
            await SmsSender.SendSmsAsync(phoneNumber, messageBody);
        }
    }

    // E-posta hatırlatmasını gönderir
    private async Task SendEmailReminderAsync(string email, Appointment appointment)
    {
        var subject = "Randevu Hatırlatması";
        var body = $"Merhaba, {appointment.Service} hizmetiniz {appointment.Date} tarihinde yapılacaktır. Lütfen zamanında gelmeye özen gösterin.";

        await EmailSender.SendEmailAsync(email, subject, body);
    }
}
