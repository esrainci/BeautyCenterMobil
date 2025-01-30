using Microsoft.AspNetCore.Mvc;
using againapi.Models;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;

namespace againapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AppointmentsController : ControllerBase
    {
        private readonly AgainApiDbContext _context;

        public AppointmentsController(AgainApiDbContext context)
        {
            _context = context;
        }

        [HttpPost("create")]
        public IActionResult CreateAppointment([FromBody] Appointment appointment)
        {
            try
            {
                if (appointment == null || string.IsNullOrEmpty(appointment.Service) || appointment.Date == default)
                {
                    return BadRequest(new { message = "Hizmet ve tarih alanları doldurulmalıdır." });
                }

                appointment.Date = DateTime.SpecifyKind(appointment.Date, DateTimeKind.Utc);

                var isConflict = _context.Appointments.Any(a => a.Date == appointment.Date && a.Service == appointment.Service);
                if (isConflict)
                {
                    return Conflict(new { message = "Bu tarih ve saatte zaten bir randevu mevcut." });
                }

                var user = _context.User.FirstOrDefault(u => u.Email == appointment.UserEmail);
                if (user != null)
                {
                    var userPoints = _context.UserPoints.FirstOrDefault(up => up.UserId == user.Id);

                    if (userPoints != null)
                    {
                        userPoints.Points += 100;
                        _context.UserPoints.Update(userPoints);
                    }
                    else
                    {
                        var newUserPoints = new UserPoints
                        {
                            UserId = user.Id,
                            Points = 100,
                            EarnedDate = DateTime.UtcNow
                        };
                        _context.UserPoints.Add(newUserPoints);
                    }

                    _context.User.Update(user);
                }

                _context.Appointments.Add(appointment);
                _context.SaveChanges();

                return Ok(new { message = "Randevunuz başarıyla oluşturuldu!", appointment });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Bir hata oluştu.", error = ex.Message });
            }
        }

        [HttpGet("available")]
        public IActionResult CheckAvailability(DateTime date, string time)
        {
            try
            {
                if (!DateTime.TryParse($"{date.ToShortDateString()} {time}", out var appointmentTime))
                {
                    return BadRequest(new { message = "Geçersiz tarih veya saat formatı." });
                }

                appointmentTime = DateTime.SpecifyKind(appointmentTime, DateTimeKind.Utc);

                var existingAppointment = _context.Appointments.FirstOrDefault(a => a.Date == appointmentTime);

                if (existingAppointment != null)
                {
                    return Ok(new { available = false, message = "Seçilen tarih ve saat dolu." });
                }

                return Ok(new { available = true, message = "Seçilen tarih ve saat uygun." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Bir hata oluştu.", error = ex.Message });
            }
        }

        [HttpGet("all")]
        public IActionResult GetAllAppointments()
        {
            return Ok(_context.Appointments.ToList());
        }

        [HttpGet("getEmployeeAppointments")]

        public async Task<IActionResult> GetEmployeeAppointments()
        {
            // Giriş yapan kullanıcının bilgilerini al
            var email = User.FindFirst(ClaimTypes.Email)?.Value;

            if (string.IsNullOrEmpty(email))
            {
                return Unauthorized(new { message = "Oturum açmanız gerekiyor." });
            }

            // Kullanıcıyı e-posta ile bul
            var user = await _context.User.FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
            {
                return NotFound(new { message = "Kullanıcı bulunamadı." });
            }

            if (user.Role != "Employee")
            {
                return StatusCode(403, new { message = "Bu işlem sadece çalışanlar için geçerlidir." });
            }

            // Kullanıcının adına atanmış randevuları getir
            var appointments = await _context.Appointments
                .Where(a => a.Employee == user.Name)
                .ToListAsync();

            if (!appointments.Any())
            {
                return NotFound(new { message = "Bu çalışanın randevusu bulunamadı." });
            }

            return Ok(appointments);
        }



        // Randevu iptali (silme)
        [HttpDelete("cancel/{appointmentId}")]
        public async Task<IActionResult> CancelAppointment(int appointmentId)
        {
            try
            {
                var appointment = await _context.Appointments.FindAsync(appointmentId);

                if (appointment == null)
                {
                    return NotFound(new { message = "Randevu bulunamadı." });
                }

                _context.Appointments.Remove(appointment);
                await _context.SaveChangesAsync();

                return Ok(new { message = "Randevu başarıyla iptal edildi." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Bir hata oluştu.", error = ex.Message });
            }
        }
    }
}
