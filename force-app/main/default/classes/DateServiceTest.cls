@isTest
private with sharing class DateServiceTest {
  @isTest
  static void testGetCurrentMonth() {
    DateService dateService = new DateService();
    Integer actualMonth = dateService.getCurrentMonth();
    Integer expectedMonth = System.today().month();
    System.assertEquals(
      expectedMonth,
      actualMonth,
      'El mes actual debe coincidir con System.today().month()'
    );
  }

  @isTest
  static void testGetToday() {
    DateService dateService = new DateService();
    Date actualToday = dateService.getToday();
    Date expectedToday = System.today();
    System.assertEquals(
      expectedToday,
      actualToday,
      'La fecha actual debe coincidir con System.today()'
    );
  }
}
