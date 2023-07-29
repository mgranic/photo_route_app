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
        // create uploads directory which will contain all uploaded albums
        string uploadsDir = Path.Combine(Directory.GetCurrentDirectory(), "uploads");
        //Create directory if it doesn't exist 
        Directory.CreateDirectory(uploadsDir);

        // create folder for each album that is being uploaded within uploads folder
        string uploadedAlbum = Path.Combine(uploadsDir, folderName);
        //Create directory if it doesn't exist 
        Directory.CreateDirectory(uploadedAlbum);

        if(files.Count == 0) return BadRequest();
            List<string> data = new List<string>();
            foreach(var file in files) {
                data.Add($"Filename: {file.FileName} || Type: {file.ContentType}");
                if (file.Length > 0)
                {
                    string filePath = Path.Combine(uploadedAlbum, file.FileName);
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
