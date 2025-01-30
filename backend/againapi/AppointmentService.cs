using againapi.Models;
using Microsoft.EntityFrameworkCore;

namespace againapi.Services
{
    public class AppointmentService : IAppointmentService
    {
        private readonly AgainApiDbContext _context;

        public AppointmentService(AgainApiDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Appointment>> GetAllAppointments()
        {
            return await _context.Appointments.ToListAsync();
        }

        public async Task<Appointment> CreateAppointment(Appointment appointment)
        {
            _context.Appointments.Add(appointment);
            await _context.SaveChangesAsync();
            return appointment;
        }
    }
}