String cronExpression = '0 0 7 * * ?';
System.schedule('DailyPlantCareReport', cronExpression, new DailyPlantCareReportScheduler());