using againapi;
using againapi.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Kullanýcý servislerini ekliyoruz
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IAppointmentService, AppointmentService>();

// Veritabaný baðlantýsý (Hem localhost hem de IP destekler)
builder.Services.AddDbContext<AgainApiDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// JWT ayarlarýný alýyoruz
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"];

// JWT doðrulama
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"],  // Localhost için
            ValidAudience = jwtSettings["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
            ClockSkew = TimeSpan.Zero // Token süresi dolduðunda hemen geçersiz kýlýnýr
        };

        options.Events = new JwtBearerEvents
        {
            OnChallenge = async context =>
            {
                context.HandleResponse();
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsync("{\"message\":\"Token doðrulama baþarýsýz. Yetkisiz eriþim.\"}");
            },
            OnAuthenticationFailed = async context =>
            {
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsync("{\"message\":\"Kimlik doðrulama hatasý: " + context.Exception.Message + "\"}");
            }
        };
    });

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Controller'larý ekliyoruz
builder.Services.AddControllers();

// CORS Ayarlarý (Hem localhost hem de Flutter için IP destekler)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowMultipleOrigins", policy =>
    {
        policy.WithOrigins(
            "https://localhost:44332",  // Web için localhost
            "https://192.168.1.35:7058" // Flutter için IP adresi
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials();
    });
});

var app = builder.Build();

// Swagger ayarlarý (Development modunda aktif)
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Middleware sýralamasý
app.UseRouting();
app.UseCors("AllowMultipleOrigins"); // Güncellenmiþ CORS politikasý
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
            message = "Sunucu hatasý oluþtu.",
            error = "Bilinmeyen hata",
            exceptionMessage,
            stackTrace = exceptionFeature?.Error?.StackTrace
        };

        await context.Response.WriteAsJsonAsync(errorMessage);
    });
});

// Controller'larý eþleþtir
app.MapControllers();

app.Run();
