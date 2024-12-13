using EventAttendeesApp.Data;
using EventAttendeesApp.Models;
using EventAttendeesApp.Pages.EventAttendees;
using Microsoft.EntityFrameworkCore;
using MockQueryable.Moq; // MockQueryableのインポート
using Moq;

namespace EventAttendeesApp.Tests
{
    [TestClass]
    public class IndexModelTests
    {
        private Mock<DbSet<EventAttendee>> _mockDbSet;
        private Mock<EventAttendeesContext> _mockContext;
        private List<EventAttendee> _attendeeData;

        [TestInitialize]
        public void TestInitialize()
        {
            // サンプルデータを作成
            _attendeeData = new List<EventAttendee>
            {
                new EventAttendee { AttendeeID = 1, EventName = "C# Conference", AttendeeName = "John Doe", Email = "john.doe@example.com", RegistrationDate = DateTime.Now },
                new EventAttendee { AttendeeID = 2, EventName = "DevOps Summit", AttendeeName = "Jane Smith", Email = "jane.smith@example.com", RegistrationDate = DateTime.Now }
            };

            // MockQueryable.Moqを使ってDbSetのモックを作成
            _mockDbSet = _attendeeData.AsQueryable().BuildMockDbSet();

            // DbContextのモックを作成
            _mockContext = new Mock<EventAttendeesContext>(new DbContextOptions<EventAttendeesContext>());
            _mockContext.Setup(c => c.EventAttendees).Returns(_mockDbSet.Object);
        }

        [TestMethod]
        public async Task OnGetAsync_ReturnsCorrectAttendees()
        {
            // Arrange
            var pageModel = new IndexModel(_mockContext.Object);

            // Act
            await pageModel.OnGetAsync();

            // Assert
            Assert.AreEqual(2, pageModel.EventAttendeeList.Count);
            Assert.AreEqual("C# Conference", pageModel.EventAttendeeList[0].EventName);
            Assert.AreEqual("John Doe", pageModel.EventAttendeeList[0].AttendeeName);
        }
    }
}
