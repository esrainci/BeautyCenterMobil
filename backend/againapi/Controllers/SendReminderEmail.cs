using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using againapi.Models;

namespace againapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AppointmentController : ControllerBase
    {
        private readonly AgainApiDbContext _context;

        public AppointmentController(AgainApiDbContext context)
        {
            _context = context;
        }

        [HttpPost("SendReminderEmail")]
        public async Task<IActionResult> SendReminderEmail(int appointmentId)
        {
            // Randevu bilgisini veritabanından al
            var appointment = await _context.Appointments.FindAsync(appointmentId);

            if (appointment == null)
            {
                return NotFound("Randevu bulunamadı.");
            }

            // Kullanıcı bilgisini al
            var user = await _context.User.FirstOrDefaultAsync(u => u.Email == appointment.UserEmail);

            if (user == null)
            {
                return NotFound("Kullanıcı bulunamadı.");
            }

            // E-posta gönderme işlemi
            var emailService = new EmailService();
            await emailService.SendEmailAsync(user.Email,
                "Randevunuz Yaklaşıyor",
                $"Yaklaşan randevunuz: {appointment.Service} - {appointment.Date}");

            return Ok("Hatırlatma e-postası gönderildi.");
        }
    }
}
