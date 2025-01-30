using againapi.Models;
using System.Collections.Generic;
using System.Linq;

public class UserService : IUserService
{
    private readonly List<User> _users = new List<User>
    {
        new User { Id = 1, Email = "test@example.com", Password = "Test1234", Name = "Test User", Role = "Customer" }
    };

    public User Authenticate(string emailOrPhone, string password)
    {
        // E-posta ya da telefon numarasını ve şifreyi kontrol ediyoruz
        var user = _users.FirstOrDefault(x =>
            (x.Email == emailOrPhone || x.Phone == emailOrPhone) && x.Password == password);

        if (user == null)
            return null;

        return user;
    }
}

