using ghRepo.Models;
using Microsoft.AspNetCore.Mvc;

namespace ghRepo.Controllers;

public class ProductsController : Controller
{
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(ILogger<ProductsController> logger)
    {
        _logger = logger;
    }

    private static readonly List<Product> Products =
    [
        new() { Id = 1, Name = "Laptop Pro 14", Description = "Laptop para tareas de oficina y desarrollo.", Price = 1499.99m, Stock = 12 },
        new() { Id = 2, Name = "Mouse Inalambrico", Description = "Mouse ergonomico con conexion Bluetooth.", Price = 29.99m, Stock = 48 },
        new() { Id = 3, Name = "Monitor 27\"", Description = "Monitor IPS Full HD para trabajo y entretenimiento.", Price = 249.90m, Stock = 20 }
    ];

    private static int _nextId = 4;

    public IActionResult Index()
    {
        return View(Products.OrderBy(p => p.Id));
    }

    public IActionResult Details(int id)
    {
        var product = Products.FirstOrDefault(p => p.Id == id);

        if (product is null)
        {
            return NotFound();
        }

        return View(product);
    }

    [HttpGet]
    public IActionResult Create()
    {
        return View(new Product());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Product product)
    {
        if (!ModelState.IsValid)
        {
            return View(product);
        }

        product.Id = _nextId++;
        Products.Add(product);

        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public IActionResult Edit(int id)
    {
        var product = Products.FirstOrDefault(p => p.Id == id);

        if (product is null)
        {
            return NotFound();
        }

        return View(new Product
        {
            Id = product.Id,
            Name = product.Name,
            Description = product.Description,
            Price = product.Price,
            Stock = product.Stock
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Edit(int id, Product product)
    {
        try
        {
            if (id != product.Id)
            {
                return BadRequest();
            }

            if (!ModelState.IsValid)
            {
                return View(product);
            }

            var existingProduct = Products.FirstOrDefault(p => p.Id == id);

            if (existingProduct is null)
            {
                return NotFound();
            }

            existingProduct.Name = product.Name;
            existingProduct.Description = product.Description;
            existingProduct.Price = product.Price;
            existingProduct.Stock = product.Stock;

            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al editar el producto con id {ProductId}", id);
            ModelState.AddModelError(string.Empty, "Ocurrio un error al guardar los cambios. Intenta nuevamente.");
            return View(product);
        }
    }

    [HttpGet]
    public IActionResult Delete(int id)
    {
        var product = Products.FirstOrDefault(p => p.Id == id);

        if (product is null)
        {
            return NotFound();
        }

        return View(product);
    }

    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int id)
    {
        var product = Products.FirstOrDefault(p => p.Id == id);

        if (product is null)
        {
            return NotFound();
        }

        Products.Remove(product);
        return RedirectToAction(nameof(Index));
    }
}