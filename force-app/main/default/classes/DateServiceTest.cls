@IsTest
private class DateServiceTest {
  @IsTest
  static void returnsTodayAndCurrentMonth() {
    DateService service = new DateService();

    System.assertEquals(System.today(), service.getToday());
    System.assertEquals(System.today().month(), service.getCurrentMonth());
  }
}
