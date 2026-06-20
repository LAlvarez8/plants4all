@RestResource(urlMapping='/weather-alert/*')
global with sharing class ForecastRestApi {
  global class ResponseDTO {
    public Integer alertsSent;
    public String status;
  }

  @HttpGet
  global static ResponseDTO executeWeatherCheck() {
    Integer alerts = WeatherAlertService.checkWeather();

    ResponseDTO response = new ResponseDTO();
    response.alertsSent = alerts;
    response.status = 'success';

    return response;
  }
}
