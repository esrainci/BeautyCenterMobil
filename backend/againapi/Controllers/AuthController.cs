using againapi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Security.Cryptography;

namespace againapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AgainApiDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(AgainApiDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] User user)
        {
            // E-posta ya da telefon ile var olup olmadığını kontrol et
            var existingUser = await _context.User
                .FirstOrDefaultAsync(u => u.Email == user.Email || u.Phone == user.Phone);

            if (existingUser != null)
            {
                return Conflict(new { message = "Bu e-posta ya da telefon numarasıyla kayıtlı bir kullanıcı zaten mevcut." });
            }

            // Şifreyi hash'le
            user.Password = HashPassword(user.Password);

            // Kullanıcıyı veritabanına ekle
            _context.User.Add(user);
            var result = await _context.SaveChangesAsync();
            if (result <= 0)
            {
                return StatusCode(500, new { message = "Kayıt sırasında bir hata oluştu." });
            }

            return Ok(new { message = "Kayıt başarılı" });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest loginRequest)
        {
            var user = await _context.User
                .FirstOrDefaultAsync(u => u.Email == loginRequest.Email || u.Phone == loginRequest.Email);

            if (user == null || !VerifyPassword(loginRequest.Password, user.Password))
            {
                return Unauthorized(new { message = "Geçersiz giriş bilgileri." });
            }

            var token = GenerateJwtToken(user);
            return Ok(new { message = "Giriş başarılı", token });
        }

        [HttpPut("updatePassword")]
        public async Task<IActionResult> UpdatePassword([FromBody] UpdatePasswordRequest request)
        {
            var email = User.FindFirst(ClaimTypes.Email)?.Value; // Kullanıcının e-postasını JWT'den al

            if (string.IsNullOrEmpty(email))
            {
                return Unauthorized(new { message = "Oturum açmanız gerekiyor." });
            }

            if (string.IsNullOrWhiteSpace(request.CurrentPassword) || string.IsNullOrWhiteSpace(request.NewPassword))
            {
                return BadRequest(new { message = "Mevcut ve yeni şifre alanları doldurulmalıdır." });
            }

            var user = await _context.User.FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
            {
                return NotFound(new { message = "Kullanıcı bulunamadı." });
            }

            // Mevcut şifreyi doğrula
            if (!VerifyPassword(request.CurrentPassword, user.Password))
            {
                return Unauthorized(new { message = "Mevcut şifre yanlış." });
            }

            // Yeni şifreyi hashle ve kaydet
            user.Password = HashPassword(request.NewPassword);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Şifre başarıyla güncellendi." });
        }


        private string GenerateJwtToken(User user)
        {
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user), "User cannot be null");
            }

            var secretKey = _configuration["JwtSettings:SecretKey"];
            if (string.IsNullOrEmpty(secretKey))
            {
                secretKey = "default_insecure_key_that_is_long_enough_to_meet_requirements"; // Varsayılan bir anahtar tanımlayın
            }

            // Anahtarı 32 byte uzunluğuna zorla
            var keyBytes = Encoding.UTF8.GetBytes(secretKey.PadRight(32, '0')); // Minimum 32 byte
            var key = new SymmetricSecurityKey(keyBytes);

            var claims = new[]
{
    new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
    new Claim(JwtRegisteredClaimNames.Email, user.Email),
    new Claim(ClaimTypes.Name, user.Name),
    new Claim(ClaimTypes.Role, user.Role)
};


            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configuration["JwtSettings:Issuer"],
                audience: _configuration["JwtSettings:Audience"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(120),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }


        private string HashPassword(string password)
        {
            using var sha256 = SHA256.Create();
            var salt = Guid.NewGuid().ToString();
            var saltedPassword = salt + password;
            var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(saltedPassword));
            return Convert.ToBase64String(hashedBytes) + ":" + salt;
        }

        private bool VerifyPassword(string inputPassword, string storedPassword)
        {
            var parts = storedPassword.Split(':');
            if (parts.Length != 2) return false;

            var salt = parts[1];
            using var sha256 = SHA256.Create();
            var hashedInput = Convert.ToBase64String(sha256.ComputeHash(Encoding.UTF8.GetBytes(salt + inputPassword)));
            return parts[0] == hashedInput;
        }
    }
}
