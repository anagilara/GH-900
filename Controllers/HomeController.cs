using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using myGHrepo.Models;

// test rebase 1
// test rebase 2
// test rebase 3
namespace myGHrepo.Controllers;

public class HomeController : Controller
{
    
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    public IActionResult Index()
    {
        try
        {
            var model = new ErrorViewModel
            {
                Message = "Welcome to the Home Page!"
            };
            return View(model);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred in Index action");
            return RedirectToAction(nameof(Error));
        }
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
