using EventAttendeesApp.Models;
using Microsoft.EntityFrameworkCore;

namespace EventAttendeesApp.Data
{
    public class EventAttendeesContext : DbContext
    {
        public EventAttendeesContext(DbContextOptions<EventAttendeesContext> options)
            : base(options)
        {
        }

        public virtual DbSet<EventAttendee> EventAttendees { get; set; }
    }
}
