public with sharing class ForecastService {
  public class ForecastException extends Exception {
  }

  public class Daily {
    public List<Decimal> temperature_2m_max;
    public List<Decimal> temperature_2m_min;
  }

  public class ForecastResponse {
    public Daily daily;
  }

  public static ForecastResponse getTodayTemperature() {
    HttpRequest req = new HttpRequest();

    req.setEndpoint(
      'callout:OpenMeteo/v1/forecast?latitude=20.03&longitude=-100.72&daily=temperature_2m_max,temperature_2m_min&timezone=auto'
    );

    req.setMethod('GET');

    Http http = new Http();

    HttpResponse res = http.send(req);

    if (res.getStatusCode() != 200) {
      throw new ForecastException(
        'OpenMeteo callout failed with status ' + res.getStatusCode()
      );
    }

    ForecastResponse forecast = (ForecastResponse) JSON.deserialize(
      res.getBody(),
      ForecastResponse.class
    );

    if (!hasTodayTemperatures(forecast)) {
      throw new ForecastException(
        'OpenMeteo response did not include today max/min temperatures'
      );
    }

    return forecast;
  }

  private static Boolean hasTodayTemperatures(ForecastResponse forecast) {
    return forecast != null &&
      forecast.daily != null &&
      forecast.daily.temperature_2m_max != null &&
      forecast.daily.temperature_2m_min != null &&
      !forecast.daily.temperature_2m_max.isEmpty() &&
      !forecast.daily.temperature_2m_min.isEmpty();
  }
}
