using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using againapi.Models;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace againapi.Controllers
{
    [Route("api/profile")]
    [ApiController]
    [Authorize]
    public class ProfileController : ControllerBase
    {
        private readonly AgainApiDbContext _context;

        public ProfileController(AgainApiDbContext context)
        {
            _context = context;
        }

        [HttpGet("getMyProfile")]
        public async Task<IActionResult> GetMyProfile()
        {
            var email = User.FindFirst(ClaimTypes.Email)?.Value;
            if (string.IsNullOrEmpty(email))
            {
                return Unauthorized(new { message = "Oturum açmanız gerekiyor." });
            }

            var user = await _context.User
                .Include(u => u.Favorites)
                .Include(u => u.Points)
                .FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
            {
                return NotFound(new { message = "Kullanıcı bulunamadı." });
            }

            var favorites = user.Favorites.Select(f => f.ServiceName).ToList();
            var points = user.Points.Select(p => new { p.Points, p.EarnedDate }).ToList();
            var appointments = await _context.Appointments
                .Where(a => a.UserEmail == email)
                .ToListAsync();

            return Ok(new
            {
                user.Name,
                user.Email,
                user.Phone,
                Favorites = favorites,
                Points = points,
                Appointments = appointments
            });
        }
        [HttpPost("addFavorite")]
        public async Task<IActionResult> AddFavorite([FromBody] Favorite favorite)
        {
            var email = User.FindFirst(ClaimTypes.Email)?.Value;

            if (string.IsNullOrEmpty(email))
            {
                return Unauthorized(new { message = "Oturum açmanız gerekiyor." });
            }

            if (string.IsNullOrWhiteSpace(favorite?.ServiceName))
            {
                return BadRequest(new { message = "Favori hizmet adı boş olamaz." });
            }

            var user = await _context.User
                .Include(u => u.Favorites)
                .FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
            {
                return NotFound(new { message = "Kullanıcı bulunamadı." });
            }

            if (user.Favorites.Any(f => f.ServiceName == favorite.ServiceName))
            {
                return Conflict(new { message = "Bu hizmet zaten favorilerde mevcut." });
            }

            user.Favorites.Add(new Favorite
            {
                ServiceName = favorite.ServiceName,
                UserId = user.Id
            });

            await _context.SaveChangesAsync();

            return Ok(new { message = "Favori hizmet başarıyla eklendi." });
        }


        [HttpDelete("removeFavorite")]
        public async Task<IActionResult> RemoveFavorite([FromBody] Favorite favorite)
        {
            var email = User.FindFirst(ClaimTypes.Email)?.Value;

            if (string.IsNullOrEmpty(email))
            {
                return Unauthorized(new { message = "Oturum açmanız gerekiyor." });
            }

            if (string.IsNullOrWhiteSpace(favorite?.ServiceName))
            {
                return BadRequest(new { message = "Favori hizmet adı boş olamaz." });
            }

            var user = await _context.User
                .Include(u => u.Favorites)
                .FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
            {
                return NotFound(new { message = "Kullanıcı bulunamadı." });
            }

            var existingFavorite = user.Favorites.FirstOrDefault(f => f.ServiceName == favorite.ServiceName);

            if (existingFavorite == null)
            {
                return NotFound(new { message = "Favori hizmet bulunamadı." });
            }

            _context.Favorite.Remove(existingFavorite);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Favori hizmet başarıyla kaldırıldı." });
        }

        // DELETE api/appointments/cancel/{appointmentId}
        [HttpDelete("cancel/{appointmentId}")]
        public async Task<IActionResult> CancelAppointment(int appointmentId)
        {
            var email = User.FindFirst(ClaimTypes.Email)?.Value;

            if (string.IsNullOrEmpty(email))
            {
                return Unauthorized(new { message = "Oturum açmanız gerekiyor." });
            }

            var appointment = await _context.Appointments
                .FirstOrDefaultAsync(a => a.Id == appointmentId && a.UserEmail == email);

            if (appointment == null)
            {
                return NotFound(new { message = "Randevu bulunamadı." });
            }

            _context.Appointments.Remove(appointment);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Randevu başarıyla iptal edildi." });
        }
    }
}
