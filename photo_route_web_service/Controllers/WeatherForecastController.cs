using Microsoft.AspNetCore.Mvc;

namespace photo_route_web_service.Controllers;

// this is test controller, not used for actuall application functionality
[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;

    /// chrome://inspect/#devices
    public WeatherForecastController(ILogger<WeatherForecastController> logger)
    {
        _logger = logger;
    }

   // https://localhost:7081/WeatherForecast?name=GetWeatherForecast
   // [HttpGet(Name = "GetWeatherForecast")]
   //https://localhost:7081/WeatherForecast/GetWeatherForecast/radiiiii
   [HttpGet("GetWeatherForecast/{param}")]
    public String Get(String param)
    {
        Console.WriteLine(param);
       return "{\"type\": \"json object\"}";
    }
   /* public IEnumerable<WeatherForecast> Get(String param)
    {
        Console.WriteLine(param);
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();
    }*/

    // https://localhost:7081/WeatherForecast/testPostRequest?param=mob_poslao
    [HttpPost("testPostRequest")]
    public String postRequestHandler(String param)
    {
        Console.WriteLine(param);
        return "response is " + param;
    }

     [HttpPost("testPostRequestBody")]
    public String postRequestBodyHandler(PostRq rq)
    {
        Console.WriteLine(rq.parameter);
        return "response is 2  " + rq.parameter;
    }
}

public class PostRq {
    public string parameter { get; set; }

}
