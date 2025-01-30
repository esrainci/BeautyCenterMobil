using againapi;
using againapi.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Kullan�c� servislerini ekliyoruz
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IAppointmentService, AppointmentService>();

// Veritaban� ba�lant�s� (Hem localhost hem de IP destekler)
builder.Services.AddDbContext<AgainApiDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// JWT ayarlar�n� al�yoruz
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"];

// JWT do�rulama
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"],  // Localhost i�in
            ValidAudience = jwtSettings["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
            ClockSkew = TimeSpan.Zero // Token s�resi doldu�unda hemen ge�ersiz k�l�n�r
        };

        options.Events = new JwtBearerEvents
        {
            OnChallenge = async context =>
            {
                context.HandleResponse();
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsync("{\"message\":\"Token do�rulama ba�ar�s�z. Yetkisiz eri�im.\"}");
            },
            OnAuthenticationFailed = async context =>
            {
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsync("{\"message\":\"Kimlik do�rulama hatas�: " + context.Exception.Message + "\"}");
            }
        };
    });

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Controller'lar� ekliyoruz
builder.Services.AddControllers();

// CORS Ayarlar� (Hem localhost hem de Flutter i�in IP destekler)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowMultipleOrigins", policy =>
    {
        policy.WithOrigins(
            "https://localhost:44332",  // Web i�in localhost
            "https://192.168.1.35:7058" // Flutter i�in IP adresi
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials();
    });
});

var app = builder.Build();

// Swagger ayarlar� (Development modunda aktif)
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Middleware s�ralamas�
app.UseRouting();
app.UseCors("AllowMultipleOrigins"); // G�ncellenmi� CORS politikas�
app.UseAuthentication();
app.UseAuthorization();

// Global hata yakalama middleware
app.UseExceptionHandler(appBuilder =>
{
    appBuilder.Run(async context =>
    {
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";

        var exceptionFeature = context.Features.Get<Microsoft.AspNetCore.Diagnostics.IExceptionHandlerFeature>();
        var exceptionMessage = exceptionFeature?.Error?.Message;

        var errorMessage = new
        {
            message = "Sunucu hatas� olu�tu.",
            error = "Bilinmeyen hata",
            exceptionMessage,
            stackTrace = exceptionFeature?.Error?.StackTrace
        };

        await context.Response.WriteAsJsonAsync(errorMessage);
    });
});

// Controller'lar� e�le�tir
app.MapControllers();

app.Run();
