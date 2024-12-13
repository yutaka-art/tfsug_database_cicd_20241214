using EventAttendeesApp.Data;
using EventAttendeesApp.Models;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace EventAttendeesApp.Pages.EventAttendees
{
    public class IndexModel : PageModel
    {
        private readonly EventAttendeesContext _context;

        public IndexModel(EventAttendeesContext context)
        {
            _context = context;
        }

        public IList<EventAttendee> EventAttendeeList { get; set; }

        public async Task OnGetAsync()
        {
            EventAttendeeList = await _context.EventAttendees.ToListAsync();
        }
    }
}
