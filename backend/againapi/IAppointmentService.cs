using againapi.Models;

namespace againapi.Services
{
    public interface IAppointmentService
    {
        Task<IEnumerable<Appointment>> GetAllAppointments();
        Task<Appointment> CreateAppointment(Appointment appointment);
    }
}