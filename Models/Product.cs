using System.ComponentModel.DataAnnotations;

namespace ghRepo.Models;

public class Product
{
    public int Id { get; set; }

    [Required(ErrorMessage = "El nombre del producto es obligatorio.")]
    [StringLength(100, ErrorMessage = "El nombre no puede superar los 100 caracteres.")]
    [Display(Name = "Nombre")]
    public string Name { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "La descripcion no puede superar los 500 caracteres.")]
    [Display(Name = "Descripcion")]
    public string? Description { get; set; }

    [Range(0.01, 999999.99, ErrorMessage = "El precio debe ser mayor que 0.")]
    [Display(Name = "Precio")]
    public decimal Price { get; set; }

    [Range(0, int.MaxValue, ErrorMessage = "El stock no puede ser negativo.")]
    [Display(Name = "Stock")]
    public int Stock { get; set; }
}