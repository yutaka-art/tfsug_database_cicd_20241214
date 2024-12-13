using System.ComponentModel.DataAnnotations;

namespace EventAttendeesApp.Models
{
    public class EventAttendee
    {
        [Key]  // 主キーを指定
        public int AttendeeID { get; set; }

        public string EventName { get; set; }

        public string AttendeeName { get; set; }

        public string Email { get; set; }

        public DateTime RegistrationDate { get; set; }
    }
}
