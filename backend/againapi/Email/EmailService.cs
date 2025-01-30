using System.Net.Mail;
using System.Net;

public class EmailService
{
    private readonly string smtpServer = "smtp.gmail.com";
    private readonly int smtpPort = 587;
    private readonly string emailAddress = "esra41devecil@gmail.com";
    private readonly string emailPassword = "yourapppassword";

    public async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        using (var client = new SmtpClient(smtpServer, smtpPort))
        {
            client.Credentials = new NetworkCredential(emailAddress, emailPassword);
            client.EnableSsl = true;

            var mailMessage = new MailMessage
            {
                From = new MailAddress(emailAddress),
                Subject = subject,
                Body = body,
                IsBodyHtml = false
            };
            mailMessage.To.Add(toEmail);

            await client.SendMailAsync(mailMessage);
        }
    }
}
