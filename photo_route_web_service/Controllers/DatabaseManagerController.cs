using System.Reflection;
using System.Net.Mime;
using Microsoft.AspNetCore.Mvc;
using photo_route_web_service.Models;
using System.Text.Encodings.Web;

namespace photo_route_web_service.Controllers;

[ApiController]
[Route("[controller]")]
public class DatabaseManagerController : Controller
{
    [HttpPost("UploadImage")]
    public String UploadImage([FromBody] ImageModel img) //[FromBody] ImageModel img
    {
       // return "neki testni kurac";
        Console.WriteLine(img.name);
        return "Image name is " + img.name;
    }
}
