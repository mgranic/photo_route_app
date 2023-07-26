using System.Reflection;
using System.Net.Mime;
using Microsoft.AspNetCore.Mvc;
using photo_route_web_service.Models;
using System.Text.Encodings.Web;

namespace photo_route_web_service.Controllers;
/// chrome://inspect/#devices
[ApiController]
[Route("[controller]")]
public class DatabaseManagerController : Controller
{
    [HttpPost("UploadImage")]
    public String UploadImage([FromBody] ImageModel img)
    {
        Console.WriteLine(img.name);
        return "Image name is " + img.name;
    }
    [HttpPost("UploadImage2")]
    [Produces("application/json")]
    [DisableRequestSizeLimit]
    public ActionResult<string>  UploadImage2([FromForm(Name = "files")] List<IFormFile> files,
                                              [FromForm] String folderName) 
    {
        //Console.WriteLine("pozvana je UploadImage2");
        //Console.WriteLine(folderName);

        string uploads = Path.Combine(Directory.GetCurrentDirectory(), folderName);
        //Create directory if it doesn't exist 
        Directory.CreateDirectory(uploads);

        if(files.Count == 0) return BadRequest();
            List<string> data = new List<string>();
            foreach(var file in files) {
                data.Add($"Filename: {file.FileName} || Type: {file.ContentType}");
                //Console.WriteLine(file.FileName);
                //Console.WriteLine(file.Length);
                //Console.WriteLine(Directory.GetCurrentDirectory());
                if (file.Length > 0)
                {
                    string filePath = Path.Combine(uploads, file.FileName);
                    using (Stream fileStream = new FileStream(filePath, FileMode.Create, FileAccess.Write))
                    {
                        file.CopyTo(fileStream);
                    }
                }
            }

            return Ok(new {
                message =  $"Uploaded {files.Count} files",
                files = data
            });
    }
}
