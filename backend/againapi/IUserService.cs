using againapi.Models;

public interface IUserService
{
    User Authenticate(string emailOrPhone, string password);
}
