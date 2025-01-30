using Microsoft.AspNetCore.Mvc;
using againapi.Models;
using System;
using System.Linq;

namespace againapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserReviewsController : ControllerBase
    {
        private readonly AgainApiDbContext _context;

        public UserReviewsController(AgainApiDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Yeni bir yorum ekler.
        /// </summary>
        [HttpPost("addReview")]
        public IActionResult AddReview([FromBody] UserReview review)
        {
            try
            {
                if (review.Rating < 1 || review.Rating > 5)
                {
                    return BadRequest(new { message = "Puan 1 ile 5 arasında olmalıdır." });
                }

                if (string.IsNullOrWhiteSpace(review.Comment))
                {
                    return BadRequest(new { message = "Yorum kısmı boş olamaz." });
                }

                if (string.IsNullOrWhiteSpace(review.UserEmail) || !review.UserEmail.Contains("@"))
                {
                    return BadRequest(new { message = "Geçerli bir e-posta adresi gereklidir." });
                }

                review.CreatedAt = DateTime.UtcNow;
                _context.UserReviews.Add(review);
                _context.SaveChanges();

                return Ok(new { message = "Yorum başarıyla eklendi!", review });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Bir hata oluştu.", error = ex.Message });
            }
        }

        /// <summary>
        /// Belirli bir kullanıcıya ait yorumları getirir.
        /// </summary>
        [HttpGet("getReviews/{userEmail}")]
        public IActionResult GetReviews(string userEmail)
        {
            if (string.IsNullOrWhiteSpace(userEmail) || !userEmail.Contains("@"))
            {
                return BadRequest(new { message = "Geçerli bir e-posta adresi gereklidir." });
            }

            var reviews = _context.UserReviews
                .Where(r => r.UserEmail == userEmail)
                .OrderByDescending(r => r.CreatedAt)
                .ToList();

            if (!reviews.Any())
            {
                return NotFound(new { message = "Bu kullanıcı için yorum bulunamadı." });
            }

            return Ok(reviews);
        }

        /// <summary>
        /// Kullanıcının kendi yorumunu günceller.
        /// </summary>
        [HttpPut("updateReview/{id}")]
        public IActionResult UpdateReview(int id, [FromBody] UserReview updatedReview)
        {
            try
            {
                var existingReview = _context.UserReviews.FirstOrDefault(r => r.Id == id && r.UserEmail == updatedReview.UserEmail);

                if (existingReview == null)
                {
                    return NotFound(new { message = "Bu e-posta adresine ait yorum bulunamadı." });
                }

                if (updatedReview.Rating < 1 || updatedReview.Rating > 5)
                {
                    return BadRequest(new { message = "Puan 1 ile 5 arasında olmalıdır." });
                }

                if (string.IsNullOrWhiteSpace(updatedReview.Comment))
                {
                    return BadRequest(new { message = "Yorum kısmı boş olamaz." });
                }

                // Güncelleme işlemleri
                existingReview.Rating = updatedReview.Rating;
                existingReview.Comment = updatedReview.Comment;
                existingReview.CreatedAt = DateTime.UtcNow;

                _context.SaveChanges();

                return Ok(new { message = "Yorum başarıyla güncellendi!", existingReview });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Bir hata oluştu.", error = ex.Message });
            }
        }

        /// <summary>
        /// Kullanıcının kendi yorumunu siler.
        /// </summary>
        [HttpDelete("deleteReview/{id}")]
        public IActionResult DeleteReview(int id, [FromQuery] string userEmail)
        {
            try
            {
                var review = _context.UserReviews.FirstOrDefault(r => r.Id == id && r.UserEmail == userEmail);

                if (review == null)
                {
                    return NotFound(new { message = "Bu e-posta adresine ait yorum bulunamadı." });
                }

                _context.UserReviews.Remove(review);
                _context.SaveChanges();

                return Ok(new { message = "Yorum başarıyla silindi!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Bir hata oluştu.", error = ex.Message });
            }
        }



        /// <summary>
        /// Tüm yorumları getirir.
        /// </summary>
        [HttpGet("getAllReviews")]
        public IActionResult GetAllReviews()
        {
            var reviews = _context.UserReviews
                .OrderByDescending(r => r.CreatedAt)
                .ToList();

            return Ok(reviews);
        }

    }
}
